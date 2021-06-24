//
//  Either+Applicative.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

@inlinable
public func <*><E, A, B>(lhs: Either<E, (A) -> B>, rhs: Either<E, A>) -> Either<E, B> {
	switch (lhs, rhs) {
	case let (.right(f), .right(a)):
		return .right(f(a))
	case let (.left(e), _):
		return .left(e)
	case let (_, .left(e)):
		return .left(e)
	}
}

@inlinable
public func pure<E, A>(_ x: A) -> Either<E, A> {
	.right(x)
}
