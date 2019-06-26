//
//  ValueStore+Array.swift
//  SioValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 26/06/2019.
//

import Foundation
import Sio

public extension ValueStore where A == B {
	func prepend<I>(_ item: I) -> SIO<R, E, A> where A == [I] {
		return self.update { array in
			return [item] + array
		}
	}
	
	func prependUnique<I: Equatable>(_ item: I) -> SIO<R, E, A> where A == [I] {
		return self.update { array in
			guard array.contains(item) == false else {
				return array
			}
			
			return [item] + array
		}
	}
	
	func append<I>(_ item: I) -> SIO<R, E, A> where A == [I] {
		return self.update { array in
			return array + [item]
		}
	}
	
	func appendUnique<I: Equatable>(_ item: I) -> SIO<R, E, A> where A == [I] {
		return self.update { array in
			guard array.contains(item) == false else {
				return array
			}
			
			return array + [item]
		}
	}
	
	func remove<I: Equatable>(_ item: I) -> SIO<R, E, A> where A == [I] {
		return self.update { array in
			return array.filter { $0 != item }
		}
	}
}
