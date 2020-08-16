//
//  SioCodecIntTests.swift
//  SioCodecTests
//
//  Created by José Manuel Sánchez Peñarroja on 03/07/2019.
//

import Foundation
import XCTest
import Sio
import SioCodec

class SIOCodecIntTests: XCTestCase {
	func testInt() {
		let codec = Codec<Void, Int, String>.int
		
		let origin = "1"
		
		let from = codec.from(origin)
		
		XCTAssert(from.right == 1)
		
		let result = from.flatMap(codec.to)
		
		XCTAssert(result.right == origin)
	}
	
	func testIntFail() {
		let codec = Codec<Void, Int, String>.int
		
		let origin = "Blah"
		
		let from = codec.from(origin)
		
		XCTAssert(from.isLeft)
	}
}
