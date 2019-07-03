//
//  SIOCodecBase64Tests.swift
//  SioCodecTests
//
//  Created by José Manuel Sánchez Peñarroja on 03/07/2019.
//

import Foundation
import XCTest
import Sio
import SioCodec

class SIOCodecBase64Tests: XCTestCase {
	func testBase64() {
		let codec = Codec<Void, String, String>.base64
		
		let origin = "Blah"
		
		let to = codec.to(origin)
		
		XCTAssert(to.right == "QmxhaA==")
		
		let result = to.flatMap(codec.from)
		
		XCTAssert(result.right == origin)
	}
}
