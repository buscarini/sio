//
//  ValueStore+Iso.swift
//  SioValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 02/07/2019.
//

import Foundation
import Sio

public func dimap<R, E, A, A0>(
	_ left: ValueStoreA<R, E, A>,
	_ iso: Iso<A, A0>
) -> ValueStoreA<R, E, A0> {
	left.dimap(iso.from, iso.to)
}

public func composeRight<R, E, A, B, C>(
	_ vs: ValueStore<R, E, A, B>,
	_ iso: Iso<B, C>
) -> ValueStore<R, E, A, C> {
	vs.dimap(id, iso.to)
}

public func >>> <R, E, A, B, C>(
	_ vs: ValueStore<R, E, A, B>,
	_ iso: Iso<B, C>
) -> ValueStore<R, E, A, C> {
	composeRight(vs, iso)
}

public func <<< <R, E, A, B, C>(
	_ iso: Iso<B, C>,
	_ vs: ValueStore<R, E, A, B>
) -> ValueStore<R, E, A, C> {
	composeRight(vs, iso)
}

public func composeLeft<R, E, A0, A, B>(
	_ iso: Iso<A0, A>,
	_ vs: ValueStore<R, E, A, B>
) -> ValueStore<R, E, A0, B> {
	vs.dimap(iso.to, id)
}

public func >>> <R, E, A0, A, B>(
	_ iso: Iso<A0, A>,
	_ vs: ValueStore<R, E, A, B>
) -> ValueStore<R, E, A0, B> {
	composeLeft(iso, vs)
}

public func <<< <R, E, A0, A, B>(
	_ vs: ValueStore<R, E, A, B>,
	_ iso: Iso<A0, A>
) -> ValueStore<R, E, A0, B> {
	composeLeft(iso, vs)
}

