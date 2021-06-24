//
//  IValueStore+Array.swift
//  SioIValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 15/2/21.
//

import Foundation
import Sio
import SioValueStore

public extension IValueStore where A == B {
	func loadAll<I>(
		key k: K,
		where pred: @escaping (I) -> Bool
	) -> SIO<R, E, A> where A == [I] {
		self.load(k).map { items in
			items.filter(pred)
		}
	}
	
	func prepend<I>(
		key k: K,
		_ item: I
	) -> SIO<R, E, A> where A == [I] {
		self.update(k) { array in
			[item] + array
		}
	}
	
	func prependUnique<I: Equatable>(
		key k: K,
		_ item: I
	) -> SIO<R, E, A> where A == [I] {
		self.update(k) { array in
			guard array.contains(item) == false else {
				return array
			}
			
			return [item] + array
		}
	}
	
	func append<I>(
		key k: K,
		_ item: I
	) -> SIO<R, E, A> where A == [I] {
		self.update(k) { array in
			array + [item]
		}
	}
	
	func appendUnique<I: Equatable>(
		key k: K,
		_ item: I
	) -> SIO<R, E, A> where A == [I] {
		self.update(k) { array in
			guard array.contains(item) == false else {
				return array
			}
			
			return array + [item]
		}
	}
	
	func remove<I: Equatable>(
		key k: K,
		_ item: I
	) -> SIO<R, E, A> where A == [I] {
		self.update(k) { array in
			array.filter { $0 != item }
		}
	}
}

public extension IValueStore where A == B, E == ValueStoreError {
	func loadSingle<I>(
		key k: K,
		_ pred: @escaping (I) -> Bool
	) -> SIO<R, E, I> where A == [I] {
		self.load(k).flatMap { items in
			SIO.from(
				items.first(where: pred),
				ValueStoreError.noData
			)
		}
	}
}
