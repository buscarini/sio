//
//  Either.swift
//  sio-iOS Tests
//
//  Created by José Manuel Sánchez Peñarroja on 02/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public enum Either<T, U> {
	case left(T)
	case right(U)
	
	public var left: T? {
		switch self {
		case let .left(left):
			return left
		case .right:
			return nil
		}
	}
	
	public var right: U? {
		switch self {
		case .left:
			return nil
		case let .right(right):
			return right
		}
	}
	
	public var isLeft: Bool {
		switch self {
		case .left:
			return true
		case .right:
			return false
		}
	}
	
	public var isRight: Bool {
		switch self {
		case .left:
			return false
		case .right:
			return true
		}
	}
	
	public func left(default value: T) -> T {
		return left ?? value
	}
	
	public func right(default value: U) -> U {
		return right ?? value
	}
	
	public func fold<A>(_ left: (T) -> A, _ right: (U) -> A) -> A {
		switch self {
		case .left(let l):
			return left(l)
		case .right(let r):
			return right(r)
		}
	}
}

extension Either: Equatable where T: Equatable, U: Equatable {
	public static func == (lhs: Either<T, U>, rhs: Either<T, U>) -> Bool {
		switch (lhs, rhs) {
		case let (.left(l1), .left(l2)):
			return l1 == l2
		case let (.right(r1), .right(r2)):
			return r1 == r2
		default:
			return false
		}
	}
}

extension Either: Hashable where T: Hashable, U: Hashable {
	public func hash(into hasher: inout Hasher) {
		switch self {
		case let .left(left):
			hasher.combine("left")
			hasher.combine(left)
		case let .right(right):
			hasher.combine("right")
			hasher.combine(right)
		}
	}
	
	
	
	//	public var hashValue: Int {
	//		switch self {
	//			case let .left(left):
	//				return HashUtils.combineHashes([ "left".hashValue, left.hashValue ])
	//			case let .right(right):
	//				return HashUtils.combineHashes([ "right".hashValue, right.hashValue ])
	//		}
	//	}
}

extension Either {
	public init(_ optional: U?, _ left: T) {
		if let value = optional {
			self = .right(value)
		}
		else {
			self = .left(left)
		}
	}
	
	public func map<V>(_ f: (U) -> V) -> Either<T, V> {
		return mapRight(f)
	}
	
	public func mapLeft<V>(_ f: (T) -> V) -> Either<V, U> {
		return bimap(f, id)
	}
	
	public func mapRight<V>(_ f: (U) -> V) -> Either<T, V> {
		return bimap(id, f)
	}
	
	public func bimap<V, W>(_ f: (T) -> V, _ g: (U) -> W) -> Either<V, W> {
		switch self {
		case let .left(left):
			return .left(f(left))
		case let .right(right):
			return .right(g(right))
		}
	}
	
	public var swapped: Either<U, T> {
		switch self {
		case let .left(left):
			return .right(left)
		case let .right(right):
			return .left(right)
		}
	}
}

extension Either where T == U {
	public func mapAll<V>(_ f: (T) -> V) -> Either<V, V> {
		return bimap(f, f)
	}
}
