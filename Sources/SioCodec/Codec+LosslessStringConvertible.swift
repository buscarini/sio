//
//  Codec+LosslessStringConvertible.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 13/05/2020.
//

import Foundation
import Sio

public extension Codec where E == Void, A == String, B: LosslessStringConvertible {
	static var stringConvertible: Codec<Void, String, B> {
		Codec<Void, String, B>(to: { string in
			Either.from(B(string), ())
		}, from: { b in
			.right(b.description)
		})
	}
}
