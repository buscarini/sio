//
//  ValueStore+Iso.swift
//  SioValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 02/07/2019.
//

import Foundation
import Sio

public func compose<R, E, A, A0>(_ left: ValueStoreA<R, E, A>, _ iso: Iso<A0, A>) -> ValueStoreA<R, E, A0> {
	return left.process({ a0 in
		return SIO<R, E, A>.of(iso.to(a0))
	}, { a in
		return SIO<R, E, A0>.of(iso.from(a))
	})
}

public func >>> <R, E, A, A0>(_ left: ValueStoreA<R, E, A>, _ iso: Iso<A0, A>) -> ValueStoreA<R, E, A0> {
	return compose(left, iso)
}

public func <<< <R, E, A, A0>(_ iso: Iso<A0, A>, _ store: ValueStoreA<R, E, A>) -> ValueStoreA<R, E, A0> {
	return compose(store, iso)
}
