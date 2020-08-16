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
		let codec = Codec<Void, Double, String>.double
		
		let origin = "1.0"
		
		let from = codec.from(origin)
		
		XCTAssert(from.right == 1)
		
		let result = from.flatMap(codec.to)
		
		XCTAssert(result.right == origin)
	}
	
	func testDoubleNoDecimals() {
		let codec = Codec<Void, Double, String>.double
		
		let origin = "1"
		
		let from = codec.from(origin)
		
		XCTAssert(from.right == 1)
		
		let result = from.flatMap(codec.to)
		
		XCTAssert(result.right == "1.0")
	}
	
	func testDoubleFail() {
		let codec = Codec<Void, Double, String>.double
		
		let origin = "Blah"
		
		let from = codec.from(origin)
		
		XCTAssert(from.isLeft)
	}
}
