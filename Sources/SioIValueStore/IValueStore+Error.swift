//
//  IValueStore+Error.swift
//  SioIValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 15/2/21.
//

import Foundation
import Sio

public extension IValueStore {
	func diMapError<F>(_ f: @escaping (E) -> F) -> IValueStore<R, K, F, A, B> {
		.init(
			load: { k in self.load(k).mapError(f) },
			save: { k, a in
				self.save(k, a).mapError(f)
			},
			remove: { k in self.remove(k).mapError(f) }
		)
	}
}
