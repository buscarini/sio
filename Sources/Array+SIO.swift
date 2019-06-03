//
//  Array+SIO.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension Array {
	public func forEach<R, E, A>(_ f: @escaping (Element) -> SIO<R, E, A>) -> SIO<R, E, [A]> {
		return sequence(self.map(f))
	}
	
	public func traverse<R, E, A>(_ f: @escaping (Element) -> SIO<R, E, A>) -> SIO<R, E, [A]> {
		return self.map(f).reduce(SIO.of([]), { acc, item in
			let concat = SIO<R, E, ([A], [A]) -> [A]>.of(+)
			return ap(concat, acc, item.map { [$0] })
		})
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


//public func sequence<R, E, A>(_ ios: [SIO<R, E, [A]>]) -> SIO<R, E, [A]> {
//	guard let first = ios.first else {
//		return SIO<R, E, [A]>.of([])
//	}
//
//	guard ios.count > 1 else {
//		return first
//	}
//
//	let rest = Array(ios.dropFirst(1))
//
//	return sequenceCont(rest, { other in
//		first.flatMap { first in
//			other.map { other in
//				first + other
//			}
//		}
//	})
//
////	return first.flatMap { values in
////		sequence(rest).map { restValues in
////			values + restValues
////		}
////		let restTask: SIO<R, E, [A]> = sequence(rest)
////		return ap(SIO.of(+), SIO.of(values), restTask)
////	}
//}


//func triCont(n: Int, cont:@escaping Int -> Int) -> Int {
//	return n <= 1 ? cont(1) : triCont(n: n-1) { r in cont(r+n) }
//}
//
//func id<A>(x: A) -> A { return x }
//
//triCont(n: 10, cont: id) // 55

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
	
//	return sequenceCont(ios, id)
}

public func sequenceCont<R, E, A>(
	_ ios: [SIO<R, E, [A]>],
	_ acc: @escaping (SIO<R, E, [A]>) -> SIO<R, E, [A]>
) -> SIO<R, E, [A]> {
	guard let first = ios.first else {
		return SIO<R, E, [A]>.of([])
	}
	
	let rest = Array(ios.dropFirst())
	
	return sequenceCont(rest, { r in
		let res = first.flatMap { first in
			r.map {
				first + $0
			}
		}
		
		return acc(res)
	})
}
