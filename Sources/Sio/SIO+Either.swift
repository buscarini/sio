//
//  SIO+Either.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	@inlinable
	static func from(_ either: Either<E, A>) -> SIO<Void, E, A> {
		switch either {
		case let .left(e):
			return SIO<Void, E, A>.rejected(e)
		case let .right(a):
			return SIO<Void, E, A>.of(a)
		}
	}
	
	@inlinable
	static func lift<B>(_ f: @escaping (A) -> Either<E, B>) -> (A) -> SIO<Void, E, B> {
		{ a in
			.from(f(a))
		}
	}
	
	@inlinable
	func either() -> SIO<R, Never, Either<E, A>> {
		self
			.map { a in
				Either<E, A>.right(a)
			}
			.flatMapError { e in
				SIO<R, Never, Either<E, A>>.of(Either<E, A>.left(e))
			}
	}
}
