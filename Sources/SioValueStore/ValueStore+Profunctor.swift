//
//  ValueStore+Profunctor.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import Sio

public extension ValueStore {
	// Profunctor dimap: T -> T => U -> T -> T -> U => U -> U
	func dimap<A0, B0>(_ pre: @escaping (A0) -> A, _ post: @escaping (B) -> B0) -> ValueStore<R, E, A0, B0> {
		return ValueStore<R, E, A0, B0>(
			load: self.load.map(post),
			save: { a0 in
				self.save(pre(a0)).map(post)
			},
			remove: self.remove
		)
	}
}
