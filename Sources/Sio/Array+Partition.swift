//
//  Array+Partition.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 23/03/2020.
//

import Foundation

public extension Array {
	func split(_ accept: (Element) -> Bool) -> (Array, Array) {
		return self.reduce( ([Element](), [Element]())
			, { acc, item in
			var (accepted, rejected) = acc
			
			accept(item) ? accepted.append(item) : rejected.append(item)
			
			return (accepted, rejected)
		})
	}
	
	func partition<B, C>(_ f: (Element) -> Either<B, C>) -> ([B], [C]) {
		return self.reduce(([],[])) { acc, item in
			var res = acc
			switch f(item) {
				case .left(let b):
					res.0.append(b)
				case .right(let c):
					res.1.append(c)
			}
			return res
		}
	}
	
	func partition<B, C>() -> ([B], [C]) where Element == Either<B, C> {
		return self.partition(id)
	}
}
