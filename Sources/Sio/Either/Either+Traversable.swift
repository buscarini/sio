//
//  Either+Traversable.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

@inlinable
public func traverseLeft<A, B, C>(_ either: Either<A, B>, _ f: @escaping (A) -> C?) -> Either<C, B>? {
	either.traverseLeft(f)
}

public extension Either {
	@inlinable
	func traverseLeft<C>(_ f: @escaping (A) -> C?) -> Either<C, B>? {
		let inside = self.mapLeft(f)
		
		switch inside {
		case let .left(.some(left)):
			return .left(left)
		case .left(nil):
			return nil
		case let .right(right):
			return .right(right)
		}
	}
	
	@inlinable
	func traverseRight<C>(_ f: @escaping (B) -> C?) -> Either<A, C>? {
		let inside = self.map(f)
		
		switch inside {
		case let .left(left):
			return .left(left)
		case let .right(.some(right)):
			return .right(right)
		case .right(nil):
			return nil
		}
	}
	
	@inlinable
	func traverse<C>(_ f: @escaping (B) -> C?) -> Either<A, C>? {
		self.traverseRight(f)
	}
}

public extension Array {
	@inlinable
	func traverse<E, B>(_ f: @escaping (Element) -> Either<E, B>) -> Either<E, [B]> {
		let initial = Either<E, [B]>.right([])
		return self.reduce(initial) { (acc: Either<E, [B]>, item: Element) in
			pure(append) <*> acc <*> f(item)
		}
	}
	
	@inlinable
	func append<B>(_ list: [B]) -> (B) -> [B] {
		{ list + [$0] }
	}
	
	@inlinable
	func sequence<E, B>() -> Either<E, [B]> where Element == Either<E, B> {
		self.traverse(id)
	}
}
