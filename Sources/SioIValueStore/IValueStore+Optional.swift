//
//  IValueStore+Optional.swift
//  SioIValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 15/2/21.
//

import Foundation
import Sio

public extension IValueStore {
	func optional() -> IValueStore<R, K, Never, A, B?> {
		.init(
			load: { k in self.load(k).optional() },
			save: { k, a in
				self.save(k, a).optional()
			},
			remove: { k in self.remove(k).optional().void }
		)
	}
}
