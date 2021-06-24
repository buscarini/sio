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
	func provide(
		_ r: R
	) -> ValueStore<Void, E, A, B> {
		.init(
			load: self.load.provide(r),
			save: { a in
				self.save(a).provide(r)
			},
			remove: self.remove.provide(r)
		)
	}
	
	func `default`(_ value: B) -> ValueStore<R, E, A, B> {
		ValueStore<R, E, A, B>(load: self.load.default(value), save: self.save, remove: self.remove)
	}
	
	func update(_ f: @escaping (B) -> A) -> SIO<R, E, B> {
		self.load
			.map(f)
			.flatMap(self.save)				
	}
	
	func pullbackR<R0>(_ f: @escaping (R0) -> R) -> ValueStore<R0, E, A ,B> {
		ValueStore<R0, E, A, B>(
			load: load.pullback(f),
			save: { a in self.save(a).pullback(f) },
			remove: self.remove.pullback(f)
		)
	}
}

public extension ValueStore where A == B {
	func migrate(from old: ValueStore) -> SIO<R, E, B> {
		migrate(from: old, with: { $0 })
	}
	
	func migrate<O>(from old: ValueStore<R, E, A, O>, with f: @escaping (O) -> B) -> SIO<R, E, B> {
		self.load
			.flatMapError { _ in
				old.load
					.map(f)
					.flatMap { value in
						self.save(value)
				}
			}
			.flatMap { value in
				old.remove.map(const(value))
		}
	}
	
	func copy<C, S>(to store: ValueStoreA<S, E, C>, adapt f: @escaping (B) -> C) -> SIO<(R, S), E, C> {
		environment((R, S).self)
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
	
	func copy<C>(to store: ValueStoreA<R, E, C>, adapt f: @escaping (B) -> C) -> SIO<R, E, C> {
		self.copy(to: store, adapt: f).pullback { r in
			(r, r)
		}
	}
	
	func move<C, S>(to store: ValueStoreA<S, E, C>, adapt f: @escaping (B) -> C) -> SIO<(R, S), E, C> {
		copy(to: store, adapt: f)
			.flatMapR { envs, value in
				self.remove.provide(envs.0).const(value).require((R, S).self)
			}
	}
	
	func move<C>(to store: ValueStoreA<R, E, C>, adapt f: @escaping (B) -> C) -> SIO<R, E, C> {
		move(to: store, adapt: f).pullback { r in
			(r, r)
		}
	}
	
	func cached(
		by cache: ValueStore<R, E, A, B>
	) -> ValueStore<R, E, A, B> {
		.init(
			load: cache.load
				.flatMapError { _ in
					self.load
				},
			save: { a in
				cache.save(a)
					.biFlatMap(self.save(a))
					.map(const(a))
			},
			remove: cache.remove.biFlatMap(self.remove).void
		)
	}
	
	func replacing(_ store: ValueStore<R, E, A, B>) -> ValueStore<R, E, A, B> {
		.init(
			load: self.load
				.flatMap { value in
					store.remove.biFlatMap(.of(value))
				}
				.flatMapError { e in
					store.move(to: self, adapt: id)
				}
			,
			save: { value in
				self.save(value)
			},
			remove: self.remove
				.flatMap { _ in
					store.remove
					.flatMapError { _ in
						.of(())
					}
				}
		)
	}
}
