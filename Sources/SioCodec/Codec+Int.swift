//
//  Codec+Int.swift
//  SioCodec
//
//  Created by José Manuel Sánchez Peñarroja on 03/07/2019.
//

import Foundation
import Sio

public extension Codec where E == Void, A == String, B == Int {
	static var int: Codec<Void, String, Int> {
		return Codec<Void, String, Int>(to: { string in
			Either.from(Int(string), ())
		}, from: { int in
			return .right("\(int)")
		})
	}
}
