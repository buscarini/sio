//
//  Codec+Int.swift
//  SioCodec
//
//  Created by José Manuel Sánchez Peñarroja on 03/07/2019.
//

import Foundation
import Sio

public extension Codec where E == Void, A == Int, B == String {
	static var int: Codec<Void, Int, String> {
		Codec.stringConvertible
	}
}

public extension Codec where E == Void, A == Float, B == String {
	static var float: Codec<Void, Float, String> {
		Codec.stringConvertible
	}
}

public extension Codec where E == Void, A == Double, B == String {
	static var double: Codec<Void, Double, String> {
		Codec.stringConvertible
	}
}
