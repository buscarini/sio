//
//  SIO+Either.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	static func from(_ either: Either<E, A>) -> SIO<Void, E, A> {
		switch either {
		case let .left(e):
			return SIO<Void, E, A>.rejected(e)
		case let .right(a):
			return SIO<Void, E, A>.of(a)
		}
	}
	
	func either() -> SIO<R, Never, Either<E, A>> {
		return self
			.map { a in
				Either<E, A>.right(a)
			}
			.flatMapError { e in
				SIO<R, Never, Either<E, A>>.of(Either<E, A>.left(e))
			}
	}
}
