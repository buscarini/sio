//
//  IValueStore+Creation.swift
//  SioIValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 15/2/21.
//

import Foundation
import Sio

public extension IValueStore {
	static func of(_ value: B) -> IValueStore<R, K, E, A, B> {
		.init(
			load: { _ in SIO.of(value) },
			save: { _, _ in
				SIO.of(value)
			},
			remove: { _ in SIO.of(()) }
		)
	}
	
	static func rejected(_ e: E) -> IValueStore<R, K, E, A, B> {
		.init(
			load: { _ in SIO.rejected(e) },
			save: { _, _ in
				SIO.rejected(e)
			},
			remove: { _ in SIO.of(()) }
		)
	}
}
