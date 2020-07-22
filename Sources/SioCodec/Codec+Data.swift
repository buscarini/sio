//
//  Codec+Data.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 01/07/2019.
//

import Foundation
import Sio

public extension Codec where E == Void, A == String, B == Data {
	static var utf8: Codec<E, A, B> {
		Codec(to: { string in
			Either.from(string.data(using: .utf8), ())
		}, from: { data in
			Either.from(String.init(data: data, encoding: .utf8), ())
		})
	}
}
