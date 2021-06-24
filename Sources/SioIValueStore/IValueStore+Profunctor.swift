//
//  File.swift
//  SioIValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 15/2/21.
//

import Foundation
import Sio

public extension IValueStore {
	// Profunctor dimap: T -> T => U -> T -> T -> U => U -> U
	func dimap<A0, B0>(
		_ pre: @escaping (A0) -> A,
		_ post: @escaping (B) -> B0
	) -> IValueStore<R, K, E, A0, B0> {
		.init(
			load: { k in self.load(k).map(post) },
			save: { k, a0 in
				self.save(k, pre(a0)).map(post)
		},
			remove: self.remove
		)
	}
	
	
	func process<A0, B0>(
		_ pre: @escaping (A0) -> SIO<R, E, A>,
		_ post: @escaping (B) -> SIO<R, E, B0>
	) -> IValueStore<R, K, E, A0, B0> {
		.init(
			load: { k in self.load(k).flatMap(post) },
			save: { k, u in
				pre(u)
					.flatMap { a in self.save(k, a) }
					.flatMap(post)
			},
			remove: self.remove
		)
	}
}
