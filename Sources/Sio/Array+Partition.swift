//
//  Array+Partition.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 23/03/2020.
//

import Foundation

public extension Array {
	func partition<B, C>(_ f: (Element) -> Either<B, C>) -> ([B], [C]) {
		self.reduce(([],[])) { acc, item in
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
		self.partition(id)
	}
}
