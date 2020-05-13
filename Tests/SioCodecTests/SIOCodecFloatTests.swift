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
		let codec = Codec<Void, String, Float>.float
		
		let origin = "1.0"
		
		let to = codec.to(origin)
		
		XCTAssert(to.right == 1)
		
		let result = to.flatMap(codec.from)
		
		XCTAssert(result.right == origin)
	}
	
	func testFloatNoDecimals() {
		let codec = Codec<Void, String, Float>.float
		
		let origin = "1"
		
		let to = codec.to(origin)
		
		XCTAssert(to.right == 1)
		
		let result = to.flatMap(codec.from)
		
		XCTAssert(result.right == "1.0")
	}
	
	func testFloatFail() {
		let codec = Codec<Void, String, Float>.float
		
		let origin = "Blah"
		
		let to = codec.to(origin)
		
		XCTAssert(to.isLeft)
	}
}
