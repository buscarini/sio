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
		Codec.stringConvertible
	}
}

public extension Codec where E == Void, A == String, B == Float {
	static var float: Codec<Void, String, Float> {
		Codec.stringConvertible
	}
}

public extension Codec where E == Void, A == String, B == Double {
	static var double: Codec<Void, String, Double> {
		Codec.stringConvertible
	}
}
