//
//  Ref+IValueStore.swift
//  SioIValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 15/2/21.
//

import Foundation
import Sio

public extension Ref {
	func iValueStore<K: Hashable, A>() -> IValueStoreA<Void, K, Void, A> where S == Dictionary<K, A> {
		.init(
			load: { k in
				.from {
					self.state[k]
				}
			},
			save: { k, newValue in
				.init {
					self.state[k] = newValue
					return .right(newValue)
				}
			},
			remove: { k in
				.init { _ in
					self.state[k] = nil
					return .right(())
				}
			}
		)
	}
}
