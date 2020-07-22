//
//  SioCodecSIOTests.swift
//  SioCodecTests
//
//  Created by José Manuel Sánchez Peñarroja on 03/07/2019.
//

import Foundation
import XCTest
import Sio
import SioCodec

class SIOCodecSIOTests: XCTestCase {
	func testCompose() {
		let origin = "Blah"
		
		let codec = Codec<Void, String, String>.base64
		
		let task = SIO<Void, Void, String>.of(origin)
		let encoded = task >>> codec
		
		encoded
		.assert("QmxhaA==")
	}
	
	func testComposeReversed() {
		let origin = "Blah"
		
		let codec = Codec<Void, String, String>.base64
		
		let task = SIO<Void, Void, String>.of(origin)
		let encoded = codec <<< task
		
		encoded
		.assert("QmxhaA==")
	}
	
	func testDecode() {
		IO<Void, String>
			.of("QmxhaA==")
			.decode(Codec.base64)
			.assert("Blah")
	}
	
	func testEncode() {
		IO<Void, String>
			.of("Blah")
			.encode(Codec.base64)
			.assert("QmxhaA==")
	}
}
