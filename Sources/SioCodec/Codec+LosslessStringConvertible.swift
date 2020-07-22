//
//  Codec+LosslessStringConvertible.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 13/05/2020.
//

import Foundation
import Sio

public extension Codec where E == Void, A == LosslessStringConvertible, B: String {
	static var stringConvertible: Codec<Void, A, B> {
		Codec<Void, A, B>(to: { string in
			.right(b.description)
		}, from: { b in
			Either.from(B(string), ())
		})
	}
}
