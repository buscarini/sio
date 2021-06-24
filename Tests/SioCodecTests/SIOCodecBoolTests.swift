//
//  SIOCodecBoolTests.swift
//  SioCodecTests
//
//  Created by José Manuel Sánchez Peñarroja on 24/08/2020.
//

import Foundation
import XCTest
import Sio
import SioCodec

class SIOCodecBoolTests: XCTestCase {
	func testBool() {
		let codec = Codec<Void, Bool, String>.bool
		
		let origin = " TRUe "
		
		let from = codec.from(origin)
		
		XCTAssert(from.right == true)
		
		let result = from.flatMap(codec.to)
		
		XCTAssert(result.right == "true")
	}
	
	func testBoolFalse() {
		let codec = Codec<Void, Bool, String>.bool
		
		let origin = "anything else"
		
		let from = codec.from(origin)
		
		XCTAssert(from.right == false)
		
		let result = from.flatMap(codec.to)
		
		XCTAssert(result.right == "false")
	}
}
