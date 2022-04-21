//
//  IValueStore+Utils.swift
//  SioIValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 15/2/21.
//

import Foundation
import Sio

public extension IValueStore {
	func `default`(_ value: B) -> IValueStore<R, K, E, A, B> {
		.init(
			load: { k in self.load(k).default(value).mapError(absurd) },
			save: self.save,
			remove: self.remove
		)
	}
	
	func update(_ key: K, _ f: @escaping (B) -> A) -> SIO<R, E, B> {
		self.load(key)
			.map(f)
			.flatMap { value in
				self.save(key, value)
			}
	}
	
	func pullbackR<R0>(_ f: @escaping (R0) -> R) -> IValueStore<R0, K, E, A ,B> {
		.init(
			load: { k in load(k).pullback(f) },
			save: { k, a in self.save(k, a).pullback(f) },
			remove: { k in self.remove(k).pullback(f) }
		)
	}
}

public extension IValueStore where A == B {
	func migrate(from old: IValueStore, key k: K) -> SIO<R, E, B> {
		migrate(from: old, key: k, with: { $0 })
	}
	
	func migrate<O>(from old: IValueStore<R, K, E, A, O>, key k: K, with f: @escaping (O) -> B) -> SIO<R, E, B> {
		self.load(k)
			.flatMapError { _ in
				old.load(k)
					.map(f)
					.flatMap { value in
						self.save(k, value)
				}
			}
			.flatMap { value in
				old.remove(k).map(const(value))
		}
	}
	
	func copy<C, S>(to store: IValueStoreA<S, K, E, C>, key k: K, adapt f: @escaping (B) -> C) -> SIO<(R, S), E, C> {
		environment((R, S).self)
			.mapError(absurd)
			.flatMap { rs in
				self.load(k)
					.provide(rs.0)
					.flatMap { b in
						store.save(k, f(b))
							.provide(rs.1)
					}
					.require((R, S).self)
			}
	}
	
	func copy<C>(to store: IValueStoreA<R, K, E, C>, key k: K, adapt f: @escaping (B) -> C) -> SIO<R, E, C> {
		self.copy(to: store, key: k, adapt: f).pullback { r in
			(r, r)
		}
	}
	
	func move<C, S>(to store: IValueStoreA<S, K, E, C>, key k: K, adapt f: @escaping (B) -> C) -> SIO<(R, S), E, C> {
		copy(to: store, key: k, adapt: f)
			.flatMapR { envs, value in
				self.remove(k).provide(envs.0).const(value).require((R, S).self)
			}
	}
	
	func move<C>(to store: IValueStoreA<R, K, E, C>, key k: K, adapt f: @escaping (B) -> C) -> SIO<R, E, C> {
		move(to: store, key: k, adapt: f).pullback { r in
			(r, r)
		}
	}
	
	func cached(
		by cache: IValueStore<R, K, E, A, B>
	) -> IValueStore<R, K, E, A, B> {
		.init(
			load: { k in
				cache.load(k)
				.flatMapError { _ in
					self.load(k)
				}
			},
			save: { k, a in
				cache.save(k, a)
					.biFlatMap(self.save(k, a))
					.map(const(a))
			},
			remove: { k in
				cache.remove(k)
					.biFlatMap(self.remove(k))
					.void
			}
		)
	}
	
	func replacing(_ store: IValueStore<R, K, E, A, B>) -> IValueStore<R, K, E, A, B> {
		.init(
			load: { k in
				self.load(k)
				.flatMap { value in
					store.remove(k).biFlatMap(.of(value))
				}
				.flatMapError { e in
					store.move(to: self, key: k, adapt: id)
				}
			},
			save: { k, value in
				self.save(k, value)
			},
			remove: { k in
				self.remove(k)
				.flatMap { _ in
					store.remove(k)
					.flatMapError { _ in
						.of(())
					}
				}
			}
		)
	}
}
