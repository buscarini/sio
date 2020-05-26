//
//  ValueStore+Contravariant.swift
//  SioValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 22/05/2020.
//

import Foundation
import Sio

public extension ValueStore {
	func pullback<A0>(
		_ f: @escaping (A0) -> A
	) -> ValueStore<R, E, A0, B> {
		self.dimap(f, id)
	}
}
