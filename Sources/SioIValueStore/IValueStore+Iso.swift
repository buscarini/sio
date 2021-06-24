//
//  IValueStore+Iso.swift
//  SioIValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 15/2/21.
//

import Foundation
import Sio

public func dimap<R, K: Hashable, E, A, A0>(
	_ left: IValueStoreA<R, K, E, A>,
	_ iso: Iso<A, A0>
) -> IValueStoreA<R, K, E, A0> {
	left.dimap(iso.from, iso.to)
}

public func composeRight<R, K: Hashable, E, A, B, C>(
	_ vs: IValueStore<R, K, E, A, B>,
	_ iso: Iso<B, C>
) -> IValueStore<R, K, E, A, C> {
	vs.dimap(id, iso.to)
}

public func >>> <R, K: Hashable, E, A, B, C>(
	_ vs: IValueStore<R, K, E, A, B>,
	_ iso: Iso<B, C>
) -> IValueStore<R, K, E, A, C> {
	composeRight(vs, iso)
}

public func <<< <R, K: Hashable, E, A, B, C>(
	_ iso: Iso<B, C>,
	_ vs: IValueStore<R, K, E, A, B>
) -> IValueStore<R, K, E, A, C> {
	composeRight(vs, iso)
}

public func composeLeft<R, K: Hashable, E, A0, A, B>(
	_ iso: Iso<A0, A>,
	_ vs: IValueStore<R, K, E, A, B>
) -> IValueStore<R, K, E, A0, B> {
	vs.dimap(iso.to, id)
}

public func >>> <R, K: Hashable, E, A0, A, B>(
	_ iso: Iso<A0, A>,
	_ vs: IValueStore<R, K, E, A, B>
) -> IValueStore<R, K, E, A0, B> {
	composeLeft(iso, vs)
}

public func <<< <R, K: Hashable, E, A0, A, B>(
	_ vs: IValueStore<R, K, E, A, B>,
	_ iso: Iso<A0, A>
) -> IValueStore<R, K, E, A0, B> {
	composeLeft(iso, vs)
}

