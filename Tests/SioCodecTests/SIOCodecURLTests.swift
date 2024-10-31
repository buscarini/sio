//
//  SIOCodecURLTests.swift
//  SioCodecTests
//
//  Created by José Manuel Sánchez Peñarroja on 23/08/2020.
//

import Foundation
import XCTest
import Sio
import SioCodec

class SIOCodecURLTests: XCTestCase {
	func testURL() {
		let codec = Codec<Void, URL, String>.url
		
		let origin = "https://www.google.com"
		
		let from = codec.from(origin)
		
		XCTAssert(from.right == URL(string: origin))
		
		let result = from.flatMap(codec.to)
		
		XCTAssert(result.right == origin)
	}
	
	func testURLFail() {
		let codec = Codec<Void, URL, String>.url
		
		let origin = "https://  á"
		
		let from = codec.from(origin)
		
		XCTAssert(from.isLeft)
	}
}
