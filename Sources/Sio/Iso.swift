//
//  Iso.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 02/07/2019.
//

import Foundation

/// Isomorphism between 2 structures. Law: compose(from, to) == id
public struct Iso<A, B> {
	public var from: (B) -> A
	public var to: (A) -> B
	
	public init(
		from: @escaping (B) -> A,
		to: @escaping (A) -> B
	) {
		self.from = from
		self.to = to
	}
}

public extension Iso {
	static func compose<C>(_ left: Iso<A, B>, _ right: Iso<B, C>) -> Iso<A, C> {
		Iso<A, C>.init(from: { c in
			left.from(right.from(c))
		}, to: { a in
			right.to(left.to(a))
		})
	}
	
	func compose<C>(_ iso: Iso<B, C>) -> Iso<A, C> {
		Iso.compose(self, iso)
	}
	
	static func >>> <C>(_ left: Iso<A, B>, _ right: Iso<B, C>) -> Iso<A, C> {
		compose(left, right)
	}
	
	static func <<< <C>(_ left: Iso<B, C>, _ right: Iso<A, B>) -> Iso<A, C> {
		compose(right, left)
	}
	
	var reversed: Iso<B, A> {
		.init(from: to, to: from)
	}
}
