//
//  IValueStore+Functor.swift
//  SioIValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 15/2/21.
//

import Foundation
import Sio

public extension IValueStore {
	func map<B0>(
		_ f: @escaping (B) -> B0
	) -> IValueStore<R, K, E, A, B0> {
		self.dimap(id, f)
	}
}
