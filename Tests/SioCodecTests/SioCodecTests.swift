//
//  SioCodecTests.swift
//  SioCodecTests
//
//  Created by José Manuel Sánchez Peñarroja on 14/12/2019.
//

import Foundation
import XCTest

import Sio
import SioCodec

class SIOCodecTests: XCTestCase {
	func testEmpty() {
		let empty = Codec<Never, Int, Int>.empty
		
		XCTAssertEqual(empty.to(1), empty.from(1))
	}
	
	func testComposeRight() {
		let left = Codec<Void, String, Int>.int
		let right = Codec<Void, Int, Int>.init(to: {
			.right($0 + 1)
		}, from: {
			.right($0 - 1)
		})
		
		let codec = left >>> right
		
		XCTAssertEqual(codec.to("1").right, 2)
		XCTAssertEqual(codec.from(3).right, "2")
	}
	
	func testComposeLeft() {
		let left = Codec<Void, String, Int>.int
		let right = Codec<Void, Int, Int>.init(to: {
			.right($0 + 1)
		}, from: {
			.right($0 - 1)
		})
		
		let codec = right <<< left
		
		XCTAssertEqual(codec.to("1").right, 2)
		XCTAssertEqual(codec.from(3).right, "2")
	}
}
