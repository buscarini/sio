//
//  ValueStore+Array.swift
//  SioValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 26/06/2019.
//

import Foundation
import Sio

public extension ValueStore where A == B {
	func loadAll<I>(
		where pred: @escaping (I) -> Bool
	) -> SIO<R, E, A> where A == [I] {
		self.load.map { items in
			items.filter(pred)
		}
	}
	
	func prepend<I>(_ item: I) -> SIO<R, E, A> where A == [I] {
		self.update { array in
			[item] + array
		}
	}
	
	func prependUnique<I: Equatable>(_ item: I) -> SIO<R, E, A> where A == [I] {
		self.update { array in
			guard array.contains(item) == false else {
				return array
			}
			
			return [item] + array
		}
	}
	
	func append<I>(_ item: I) -> SIO<R, E, A> where A == [I] {
		self.update { array in
			array + [item]
		}
	}
	
	func appendUnique<I: Equatable>(_ item: I) -> SIO<R, E, A> where A == [I] {
		self.update { array in
			guard array.contains(item) == false else {
				return array
			}
			
			return array + [item]
		}
	}
	
	func remove<I: Equatable>(_ item: I) -> SIO<R, E, A> where A == [I] {
		self.update { array in
			array.filter { $0 != item }
		}
	}
}

public extension ValueStore where A == B, E == ValueStoreError {
	func loadSingle<I>(
		_ pred: @escaping (I) -> Bool
	) -> SIO<R, E, I> where A == [I] {
		self.load.flatMap { items in
			SIO.from(
				items.first(where: pred),
				ValueStoreError.noData
			)
		}
	}
}
