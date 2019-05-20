//
//  Array+SIO.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension Array {
	public func traverse<R, E, A>(_ f: @escaping (Element) -> SIO<R, E, A>) -> SIO<R, E, [A]> {
		return self.reduce(SIO.of([])) { acc, item in
			let current = f(item).map { [$0] }
			
			let concat = SIO<R, E, ([A], [A]) -> [A]>.of(+)
			
			return ap(concat, acc, current)
		}
	}
}

public func parallel<R, E, A>(_ ios: [SIO<R, E, A>]) -> SIO<R, E, [A]> {
	return ios.traverse({ $0 })
}

public func concat<R, E, A>(_ first: SIO<R, E, [A]>, _ second: SIO<R, E, [A]>) -> SIO<R, E, [A]> {
	return ap(SIO.of(+), first, second)
}

public func parallel<R, E, A>(_ ios: [SIO<R, E, [A]>]) -> SIO<R, E, [A]> {
	return ios.reduce(SIO.of([])) { acc, item in
		return concat(acc, item)
	}
}

public func sequence<R, E, A>(_ ios: [SIO<R, E, A>]) -> SIO<R, E, [A]> {
	return sequence(ios.map { io in
		io.map { [$0] }
	})
}

public func sequence<R, E, A>(_ ios: [SIO<R, E, [A]>]) -> SIO<R, E, [A]> {
	guard let first = ios.first else {
		return SIO<R, E, [A]>.of([])
	}
	
	return first.flatMap { values in
		let rest: SIO<R, E, [A]> = sequence(Array(ios.dropFirst(1)))
		return ap(SIO.of(+), SIO.of(values), rest)
	}
}

