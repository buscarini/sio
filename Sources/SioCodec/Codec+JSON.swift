//
//  Codec+JSONCodable.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 01/07/2019.
//

import Foundation
import Sio

public extension Codec where E == Error, A: Codable, B == Data {
	@inlinable
	static var json: Codec<Error, A, Data> {
		jsonCodec(JSONDecoder(), JSONEncoder())
	}
	
	@inlinable
	static func jsonCodec(
		_ decoder: JSONDecoder,
		_ encoder: JSONEncoder
	) -> Codec<Error, A, Data> {
		Codec<Error, A, Data>(to: { value in
			Either<Error, Data>.init(catching: {
				try encoder.encode(value)
			})
		}, from: { data in
			Either<Error, A>.init(catching: {
				try decoder.decode(A.self, from: data)
			})
		})
	}
}
