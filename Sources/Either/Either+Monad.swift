//
//  Either+Monad.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension Either {
	public func flatMap<V>(_ f: (U) -> Either<T, V>) -> Either<T, V> {
		return flatMapRight(f)
	}
	
	public func flatMapLeft<V>(_ f: (T) -> Either<V, U>) -> Either<V, U> {
		return biFlatMap(f, { (right) -> Either<V, U> in
			return .right(right)
		})
	}
	
	public func flatMapRight<V>(_ f: (U) -> Either<T, V>) -> Either<T, V> {
		return biFlatMap({ (left) -> Either<T, V> in
			return .left(left)
		}, f)
	}
	
	public func biFlatMap<V, W>(_ f: (T) -> Either<V, W>, _ g: (U) -> Either<V, W>) -> Either<V, W> {
		switch self {
		case let .left(left):
			return f(left)
		case let .right(right):
			return g(right)
		}
	}
}

public func >>= <T, U, V>(_ a: Either<T, U>, _ f: (U) -> Either<T, V>) -> Either<T, V> {
	return a.flatMap(f)
}
