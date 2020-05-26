//
//  ValueStore+Functor.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 22/05/2020.
//

import Foundation
import Sio

public extension ValueStore {
	func map<B0>(
		_ f: @escaping (B) -> B0
	) -> ValueStore<R, E, A, B0> {
		self.dimap(id, f)
	}
}
