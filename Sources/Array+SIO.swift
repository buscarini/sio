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
		return sequence(self.map(f))
	}
	
	@inlinable
	public func traverse<R, E, A>(_ f: @escaping (Element) -> SIO<R, E, A>) -> SIO<R, E, [A]> {
		return self.map(f).reduce(SIO.of([]), { acc, item in
			let concat = SIO<R, E, ([A], [A]) -> [A]>.of(+)
			return ap(concat, acc, item.map { [$0] })
		})
	}
}

@inlinable
public func parallel<R, E, A>(_ ios: [SIO<R, E, A>]) -> SIO<R, E, [A]> {
	return ios.traverse({ $0 })
}

@inlinable
public func concat<R, E, A>(_ first: SIO<R, E, [A]>, _ second: SIO<R, E, [A]>) -> SIO<R, E, [A]> {
	return ap(SIO.of(+), first, second)
}

@inlinable
public func parallel<R, E, A>(_ ios: [SIO<R, E, [A]>]) -> SIO<R, E, [A]> {
	return ios.reduce(SIO.of([])) { acc, item in
		return concat(acc, item)
	}
}

@inlinable
public func sequence<R, E, A>(_ ios: [SIO<R, E, A>]) -> SIO<R, E, [A]> {
	return sequence(ios.map { io in
		io.map { [$0] }
	})
}

@inlinable
public func sequence<R, E, A>(
	_ ios: [SIO<R, E, [A]>]
) -> SIO<R, E, [A]> {
	
	return ios.reduce(SIO<R, E, [A]>.of([]), { acc, item in
		let concat = SIO<R, E, ([A], [A]) -> [A]>.of(+)
		return ap(concat, acc, item)
	})
//
//	guard var previous = ios.first else {
//		return SIO<R, E, [A]>.of([])
//	}
//
//	let rest = ios.dropFirst()
//
//	for io in rest {
//		previous = previous.flatMap({ left in
//			io.map { right in
//				left + right
//			}
//		})
//	}
//
//	return previous
}
