//
//  ValueStore+Creation.swift
//  SioValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//

import Foundation
import Sio

public extension ValueStore {
	static func of(_ value: B) -> ValueStore<R, E, A, B> {
		return ValueStore<R, E, A, B>(
			load: SIO.of(value),
			save: { a in
				return SIO.of(value)
			},
			remove: SIO.of(())
		)
	}
	
	static func rejected(_ e: E) -> ValueStore<R, E, A, B> {
		return ValueStore<R, E, A, B>(
			load: SIO.rejected(e),
			save: { _ in
				return SIO.rejected(e)
			},
			remove: SIO.of(())
		)
	}
}
