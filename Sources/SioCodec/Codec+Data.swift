//
//  Codec+Data.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 01/07/2019.
//

import Foundation
import Sio

public extension Codec where E == Void, A == Data, B == String {
	static var utf8: Codec<Void, Data, String> {
		return Codec<Void, Data, String>(to: { data in
			Either.from(String.init(data: data, encoding: .utf8), ())
		}, from: { string in
			Either.from(string.data(using: .utf8), ())
		})
	}
}
