//
//  Either+Optional.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 01/07/2019.
//

import Foundation

public extension Either {
	static func from(_ optional: B?, default value: B) -> Either<A, B> {
		.right(optional ?? value)
	}
	
	static func from(_ optional: B?, _ error: A) -> Either {
		if let value = optional {
			return .right(value)
		}
		else {
			return .left(error)
		}
	}
	
	func optional() -> B? {
		self.right
	}
}
