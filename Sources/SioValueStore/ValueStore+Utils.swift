//
//  ValueStore+UTils.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import Sio

public extension ValueStore {
	func `default`(_ value: B) -> ValueStore<R, E, A, B> {
		return ValueStore<R, E, A, B>(load: self.load.default(value), save: self.save, remove: self.remove)
	}
	
	func update(_ f: @escaping (B?) -> A?) -> SIO<R, E, B> {
		return self.load
			.flatMap { value in
				guard let a = f(value) else {
					return .of(value)
				}
				
				return self.save(a)
			}
	}
	
	func pullbackR<R0>(_ f: @escaping (R0) -> R) -> ValueStore<R0, E, A ,B> {
		return ValueStore<R0, E, A, B>(
			load: load.pullback(f),
			save: { a in self.save(a).pullback(f) },
			remove: self.remove.pullback(f)
		)
	}
}

public extension ValueStore where A == B {
	func migrate(from old: ValueStore) -> SIO<R, E, B> {
		return migrate(from: old, with: { $0 })
	}
	
	func migrate<O>(from old: ValueStore<R, E, A, O>, with f: @escaping (O) -> B) -> SIO<R, E, B> {
		return self.load
			.flatMapError { _ in
				return old.load
					.map(f)
					.flatMap { value in
						self.save(value)
				}
			}
			.flatMap { value in
				old.remove.map(const(value))
		}
	}
	
	func copy<C, S>(to store: ValueStore<S, E, C, C>, adapt f: @escaping (B) -> C) -> SIO<(R, S), E, C> {
		return environment((R, S).self)
			.mapError(absurd)
			.flatMap { rs in
				self.load
					.provide(rs.0)
					.flatMap { b in
						store.save(f(b))
							.provide(rs.1)
					}
					.require((R, S).self)
			}
	}
}
