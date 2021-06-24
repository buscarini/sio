//
//  ValueStore+Codec.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 01/07/2019.
//

import Foundation
import Sio
import SioCodec

@inlinable
public func compose<R, E, A, A0>(_ left: ValueStoreA<R, E, A>, _ codec: Codec<E, A0, A>) -> ValueStoreA<R, E, A0> {
	left.process({ a0 in
		SIO<R, E, A>.from(codec.to(a0)).require(R.self)
	}, { a in
		SIO<R, E, A0>.from(codec.from(a)).require(R.self)
	})
}

@inlinable
public func >>> <R, E, A, A0>(_ left: ValueStoreA<R, E, A>, _ codec: Codec<E, A0, A>) -> ValueStoreA<R, E, A0> {
	compose(left, codec)
}

@inlinable
public func <<< <R, E, A, A0>(_ codec: Codec<E, A0, A>, _ store: ValueStoreA<R, E, A>) -> ValueStoreA<R, E, A0> {
	compose(store, codec)
}

public extension ValueStore where A == B {
	@inlinable
	func coded<A0>(_ codec: Codec<E, A0, A>) -> ValueStoreA<R, E, A0> {
		self >>> codec
	}
}
