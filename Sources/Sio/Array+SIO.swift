//
//  Array+SIO.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension Array {
	@inlinable
	public func forEach<R, E, A>(_ f: @escaping (Element) -> SIO<R, E, A>) -> SIO<R, E, [A]> {
		Sio.sequence(self.map(f))
	}
	
	@inlinable
	public func traverse<R, E, A>(
		_ scheduler: Scheduler,
		_ f: @escaping (Element) -> SIO<R, E, A>
	) -> SIO<R, E, [A]> {
		guard let first = self.first else {
			return .of([])
		}

		guard self.count > 1 else {
			return f(first).map { [$0] }
		}

		let concat = SIO<R, E, ([A], [A]) -> [A]>.of(+)
		let half = self.count/2
		let left = self[0..<half]
		let right = self[half..<count]

		return ap(
			concat,
			Array(left).traverse(scheduler, f),
			Array(right).traverse(scheduler, f),
			scheduler
		)
	}
	
	@inlinable
	public func wither<R, E, A>(
		_ scheduler: Scheduler,
		_ f: @escaping (Element) -> SIO<R, E, A?>
	) -> SIO<R, E, [A]> {
		guard let first = self.first else {
			return .of([])
		}

		guard self.count > 1 else {
			return f(first).map { [$0].compactMap { $0 } }
		}

		let concat = SIO<R, E, ([A], [A]) -> [A]>.of(+)
		let half = self.count/2
		let left = self[0..<half]
		let right = self[half..<count]

		return ap(
			concat,
			Array(left).wither(scheduler, f),
			Array(right).wither(scheduler, f),
			scheduler
		)
	}
	
	public func foldM<R, E, S>(_ initial: S, _ f: @escaping (S, Element) -> SIO<R, E, S>) -> SIO<R, E, S> {
		return self.reduce(SIO<R, E, S>.of(initial)) { acc, item in
			acc.flatMap { s in
				f(s, item)
			}
		}
	}
}

@inlinable
public func parallel<R, E, A>(
	_ ios: [SIO<R, E, A>],
	_ scheduler: Scheduler
) -> SIO<R, E, [A]> {
	ios.traverse(scheduler) { $0 }
}

@inlinable
public func concat<R, E, A>(
	_ first: SIO<R, E, [A]>,
	_ second: SIO<R, E, [A]>,
	_ scheduler: Scheduler
) -> SIO<R, E, [A]> {
	ap(SIO.of(+), first, second, scheduler)
}

@inlinable
public func sequence<R, E, A>(_ ios: [SIO<R, E, A>]) -> SIO<R, E, [A]> {
	sequence(ios.map { io in
		io.map { [$0] }
	})
}

@inlinable
public func sequence<R, E, A>(
	_ ios: [SIO<R, E, [A]>]
) -> SIO<R, E, [A]> {
	
	guard var previous = ios.first else {
		return SIO<R, E, [A]>.of([])
	}

	let rest = ios.dropFirst()

	for io in rest {
		previous = previous.flatMap({ left in
			io.map { right in
				left + right
			}
		})
	}

	return previous
}
