//
//  SIOCodecUTF8Tests.swift
//  SioCodecTests
//
//  Created by José Manuel Sánchez Peñarroja on 03/07/2019.
//

import Foundation
import XCTest
import Sio
import SioCodec

class SIOCodecUTF8Tests: XCTestCase {
	func testUTF8() {
		let codec = Codec<Void, String, Data>.utf8
		
		let origin = "Blah"
		
		let result = codec.to(origin).flatMap(codec.from)
		
		XCTAssert(result.right == origin)
	}
}
