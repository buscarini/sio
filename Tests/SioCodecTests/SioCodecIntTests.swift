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
		let codec = Codec<Void, String, Int>.int
		
		let origin = "1"
		
		let to = codec.to(origin)
		
		XCTAssert(to.right == 1)
		
		let result = to.flatMap(codec.from)
		
		XCTAssert(result.right == origin)
	}
	
	func testIntFail() {
		let codec = Codec<Void, String, Int>.int
		
		let origin = "Blah"
		
		let to = codec.to(origin)
		
		XCTAssert(to.isLeft)
	}
}
