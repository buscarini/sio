//
//  IValueStore+Contravariant.swift
//  SioIValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 15/2/21.
//

import Foundation
import Sio

public extension IValueStore {
	func pullback<A0>(
		_ f: @escaping (A0) -> A
	) -> IValueStore<R, K, E, A0, B> {
		self.dimap(f, id)
	}
}
