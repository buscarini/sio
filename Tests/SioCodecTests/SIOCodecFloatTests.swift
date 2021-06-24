//
//  SIOCodecFloatTests.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 13/05/2020.
//

import Foundation
import XCTest
import Sio
import SioCodec

class SIOCodecFloatTests: XCTestCase {
	func testFloat() {
		let codec = Codec<Void, Float, String>.float
		
		let origin = "1.0"
		
		let from = codec.from(origin)
		
		XCTAssert(from.right == 1)
		
		let result = from.flatMap(codec.to)
		
		XCTAssert(result.right == origin)
	}
	
	func testFloatNoDecimals() {
		let codec = Codec<Void, Float, String>.float
		
		let origin = "1"
		
		let from = codec.from(origin)
		
		XCTAssert(from.right == 1)
		
		let result = from.flatMap(codec.to)
		
		XCTAssert(result.right == "1.0")
	}
	
	func testFloatFail() {
		let codec = Codec<Void, Float, String>.float
		
		let origin = "Blah"
		
		let from = codec.from(origin)
		
		XCTAssert(from.isLeft)
	}
}
