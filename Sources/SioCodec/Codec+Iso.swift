//
//  Codec+Iso.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 02/07/2019.
//

import Foundation
import Sio

public extension Codec {
	static func lift(_ iso: Iso<A, B>) -> Codec<Never, A, B> {
		return Codec<Never, A, B>.init(to: { a in
			.right(iso.to(a))
		}, from: { b in
			.right(iso.from(b))
		})
	}
	
	static func compose<C>(_ left: Codec<E, A, B>, _ right: Iso<B, C>) -> Codec<E, A, C> {
		return Codec<E, A, C>.init(to: { a in
			left.to(a).map(right.to)
		}, from: { c in
			left.from(right.from(c))
		})
	}
	
	static func >>> <C>(_ left: Codec<E, A, B>, _ right: Iso<B, C>) -> Codec<E, A, C> {
		return compose(left, right)
	}
	
	static func <<< <C>(_ left: Iso<B, C>, _ right: Codec<E, A, B>) -> Codec<E, A, C> {
		return compose(right, left)
	}
}
