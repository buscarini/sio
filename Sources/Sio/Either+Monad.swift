//
//  Either+Monad.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension Either {
	public func flatMap<V>(_ f: (B) -> Either<A, V>) -> Either<A, V> {
		return flatMapRight(f)
	}
	
	public func flatMapLeft<V>(_ f: (A) -> Either<V, B>) -> Either<V, B> {
		return biFlatMap(f, { (right) -> Either<V, B> in
			return .right(right)
		})
	}
	
	public func flatMapRight<V>(_ f: (B) -> Either<A, V>) -> Either<A, V> {
		return biFlatMap({ (left) -> Either<A, V> in
			return .left(left)
		}, f)
	}
	
	public func biFlatMap<V, W>(_ f: (A) -> Either<V, W>, _ g: (B) -> Either<V, W>) -> Either<V, W> {
		switch self {
		case let .left(left):
			return f(left)
		case let .right(right):
			return g(right)
		}
	}
}

public func >>= <A, B, V>(_ a: Either<A, B>, _ f: (B) -> Either<A, V>) -> Either<A, V> {
	return a.flatMap(f)
}
