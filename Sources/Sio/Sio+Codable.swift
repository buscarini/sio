//
//  Sio+Codable.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 29/11/2019.
//

import Foundation

public extension SIO where A: Encodable, E == Error {
	@inlinable
	func encode(encoder: JSONEncoder) -> SIO<R, E, Data> {
		self.flatMap { a in
			.init(catching: { _ in
				try encoder.encode(a)
			})
		}
	}
}

public extension SIO where A == Data, E == Error {
	@inlinable
	func decode<T: Decodable>(_ type: T.Type, decoder: JSONDecoder) -> SIO<R, E, T> {
		self.flatMap { data in
			.init(catching: { _ in
				try decoder.decode(T.self, from: data)
			})
		}
	}
}
