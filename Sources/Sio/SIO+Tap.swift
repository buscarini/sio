//
//  SIO+Tap.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//

import Foundation

public extension SIO {
	@inlinable
	func tap(_ f: @escaping (A) -> SIO<R, E, Void>) -> SIO<R, E, A> {
		self.flatMap { a in
			f(a).const(a)
		}
	}
	
	@inlinable
	func tapError(_ f: @escaping (E) -> SIO<R, E, Void>) -> SIO<R, E, A> {
		self.flatMapError { e in
			f(e).flatMap { _ in
				.rejected(e)
			}
		}
	}
	
	@inlinable
	func tapBoth(_ f: @escaping (E) -> SIO<R, E, Void>, _ g: @escaping (A) -> SIO<R, E, Void>) -> SIO<R, E, A> {
		self
			.tap(g)
			.tapError(f)
	}
}
