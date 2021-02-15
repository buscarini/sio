//
//  IValueStore+Codec.swift
//  SioIValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 15/2/21.
//

import Foundation
import Sio
import SioCodec

@inlinable
public func compose<R, E, K: Hashable, A, A0>(_ left: IValueStoreA<R, K, E, A>, _ codec: Codec<E, A0, A>) -> IValueStoreA<R, K, E, A0> {
	left.process({ a0 in
		SIO<R, E, A>.from(codec.to(a0)).require(R.self)
	}, { a in
		SIO<R, E, A0>.from(codec.from(a)).require(R.self)
	})
}

@inlinable
public func >>> <R, K: Hashable, E, A, A0>(_ left: IValueStoreA<R, K, E, A>, _ codec: Codec<E, A0, A>) -> IValueStoreA<R, K, E, A0> {
	compose(left, codec)
}

@inlinable
public func <<< <R, K: Hashable, E, A, A0>(_ codec: Codec<E, A0, A>, _ store: IValueStoreA<R, K, E, A>) -> IValueStoreA<R, K, E, A0> {
	compose(store, codec)
}

public extension IValueStore where A == B {
	@inlinable
	func coded<A0>(_ codec: Codec<E, A0, A>) -> IValueStoreA<R, K, E, A0> {
		self >>> codec
	}
}
