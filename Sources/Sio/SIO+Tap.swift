//
//  SIO+Tap.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//

import Foundation

public extension SIO {
	func tap(_ f: @escaping (A) -> SIO<R, E, Void>) -> SIO<R, E, A> {
		return self.flatMap { a in
			f(a).const(a)
		}
	}
	
	func tapError(_ f: @escaping (E) -> SIO<R, E, Void>) -> SIO<R, E, A> {
		return self.flatMapError { e in
			f(e).flatMap { _ in
				.rejected(e)
			}
		}
	}
	
	func tapBoth(_ f: @escaping (E) -> SIO<R, E, Void>, _ g: @escaping (A) -> SIO<R, E, Void>) -> SIO<R, E, A> {
		return self
			.tap(g)
			.tapError(f)
	}
}
