//
//  SIOCodecDoubleTests.swift
//  SioCodecTests
//
//  Created by José Manuel Sánchez Peñarroja on 30/05/2020.
//

import Foundation
import XCTest
import Sio
import SioCodec

class SIOCodecDoubleTests: XCTestCase {
	func testDouble() {
		let codec = Codec<Void, String, Double>.double
		
		let origin = "1.0"
		
		let to = codec.to(origin)
		
		XCTAssert(to.right == 1)
		
		let result = to.flatMap(codec.from)
		
		XCTAssert(result.right == origin)
	}
	
	func testDoubleNoDecimals() {
		let codec = Codec<Void, String, Double>.double
		
		let origin = "1"
		
		let to = codec.to(origin)
		
		XCTAssert(to.right == 1)
		
		let result = to.flatMap(codec.from)
		
		XCTAssert(result.right == "1.0")
	}
	
	func testDoubleFail() {
		let codec = Codec<Void, String, Double>.double
		
		let origin = "Blah"
		
		let to = codec.to(origin)
		
		XCTAssert(to.isLeft)
	}
}
