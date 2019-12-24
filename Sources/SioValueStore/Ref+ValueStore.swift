//
//  Ref+ValueStore.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 23/12/2019.
//

import Foundation
import Sio

public extension Ref where S: IsOptional {
	func valueStore() -> ValueStoreA<Void, Void, S.Wrapped> {
		.init(
			load: .from {
				self.state.some
			},
			save: { newValue in
				.init {
					self.state.some = newValue
					return .right(newValue)
				}
			},
			remove: .init{ _ in
				self.state.some = nil
				return .right(())
			}
		)
	}
}
