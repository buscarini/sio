//
//  Codec+Bool.swift
//  SioCodec
//
//  Created by José Manuel Sánchez Peñarroja on 22/07/2020.
//

import Foundation
import Foundation
import Sio

public extension Codec where E == Void, A == Bool, B == String {
	static var bool: Codec<Void, Bool, String> {
		Codec<Void, Bool, String>(to: { bool in
			.right(bool ? "true" : "false")
		}, from: { s in
			.right(
				s
					.trimmingCharacters(in:
					.whitespacesAndNewlines).lowercased()
				== "true"
			)
		})
	}
}
