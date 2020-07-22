//
//  Codec+Base84.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 01/07/2019.
//

import Foundation
import Sio

public extension Codec where E == Void, A == String, B == String {
	static var base64: Codec<E, A, B> {
		Codec(to: { decoded in
			Either.from(decoded.data(using: .utf8), ())
				.map { $0.base64EncodedString() }
		}, from: { encoded in
			Either.from(Data.init(base64Encoded: encoded, options: []), ())
				.flatMap { data in
					Either.from(String.init(data: data, encoding: .utf8), ())
			}
		})
	}
}
