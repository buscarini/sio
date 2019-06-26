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
	
	
	func transform<A0, B0>(_ pre: @escaping (A0) -> SIO<R, E, A>, _ post: @escaping (B) -> SIO<R, E, B0>) -> ValueStore<R, E, A0, B0> {
		return ValueStore<R, E, A0, B0>(
			load: self.load.flatMap(post),
			save: { u in pre(u).flatMap(self.save).flatMap(post) },
			remove: self.remove
		)
	}
	
//	(a -> ValueStore a0 b) => ValueStore a b => (b -> ValueStore a c) = ValueStore a0 c
//	func diFlatMap<A0, B0>(_ pre: @escaping (A0) -> ValueStore<R, E, A, B>, _ post: @escaping (B) -> ValueStore<R, E, A, B0>) -> ValueStore<R, E, A0, B0> {
//		return ValueStore<R, E, A0, B0>(
//			load: self.load.flatMap { b in
//				post(b).load
//			},
//			save: { a0 in
//				
//				
//				pre(a0).save
//				
//				
//				self.save(pre(a0)).map(post)
//		},
//			remove: self.remove
//		)
//	}
}
