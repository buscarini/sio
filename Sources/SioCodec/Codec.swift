//
//  Codec.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 01/07/2019.
//

import Foundation
import Sio

public struct Codec<E, A, B> {
	public var to: (A) -> Either<E, B>
	public var from: (B) -> Either<E, A>
	
	public init(
		to: @escaping (A) -> Either<E, B>,
		from: @escaping (B) -> Either<E, A>
	) {
		self.to = to
		self.from = from
	}
}

public extension Codec {
	static func compose<C>(_ left: Codec<E, A, B>, _ right: Codec<E, B, C>) -> Codec<E, A, C> {
		Codec<E, A, C>.init(to: { a in
			left.to(a).flatMap(right.to)
		}, from: { c in
			right.from(c).flatMap(left.from)
		})
	}
	
	static func >>> <C>(_ left: Codec<E, A, B>, _ right: Codec<E, B, C>) -> Codec<E, A, C> {
		return compose(left, right)
	}
	
	static func <<< <C>(_ left: Codec<E, B, C>, _ right: Codec<E, A, B>) -> Codec<E, A, C> {
		return compose(right, left)
	}
	
	func mapError<F>(_ f: @escaping (E) -> F) -> Codec<F, A, B> {
		return Codec<F, A, B>.init(
			to: { self.to($0).mapLeft(f) },
			from: { self.from($0).mapLeft(f) }
		)
	}
}

public extension Codec where A == B {
	static var empty: Codec<E, A, A> {
		return Codec<E, A, A>.init(to: { .right($0) }, from: { .right($0) })
	}
}
