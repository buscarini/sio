//
//  Either.swift
//  sio-iOS Tests
//
//  Created by José Manuel Sánchez Peñarroja on 02/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public enum Either<A, B> {
	case left(A)
	case right(B)
	
	public var left: A? {
		switch self {
		case let .left(left):
			return left
		case .right:
			return nil
		}
	}
	
	public var right: B? {
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
	
	@inlinable
	public var isRight: Bool {
		switch self {
		case .left:
			return false
		case .right:
			return true
		}
	}
	
	@inlinable
	public func left(default value: A) -> A {
		left ?? value
	}
	
	@inlinable
	public func right(default value: B) -> B {
		right ?? value
	}
	
	@inlinable
	public func fold<C>(_ left: (A) -> C, _ right: (B) -> C) -> C {
		switch self {
		case .left(let l):
			return left(l)
		case .right(let r):
			return right(r)
		}
	}
}

extension Either: Equatable where A: Equatable, B: Equatable {
	@inlinable
	public static func == (lhs: Either<A, B>, rhs: Either<A, B>) -> Bool {
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

extension Either: Hashable where A: Hashable, B: Hashable {
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
}

extension Either {
	@inlinable
	public func map<V>(_ f: (B) -> V) -> Either<A, V> {
		mapRight(f)
	}
	
	@inlinable
	public func mapLeft<V>(_ f: (A) -> V) -> Either<V, B> {
		bimap(f, id)
	}
	
	@inlinable
	public func mapRight<V>(_ f: (B) -> V) -> Either<A, V> {
		bimap(id, f)
	}
	
	@inlinable
	public func bimap<V, W>(_ f: (A) -> V, _ g: (B) -> W) -> Either<V, W> {
		switch self {
		case let .left(left):
			return .left(f(left))
		case let .right(right):
			return .right(g(right))
		}
	}
	
	@inlinable
	public var swapped: Either<B, A> {
		switch self {
		case let .left(left):
			return .right(left)
		case let .right(right):
			return .left(right)
		}
	}
}

extension Either where A == B {
	@inlinable
	public func mapAll<V>(_ f: (A) -> V) -> Either<V, V> {
		bimap(f, f)
	}
}
