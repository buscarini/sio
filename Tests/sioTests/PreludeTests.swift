//
//  PreludeTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 01/12/2019.
//

import Foundation
import XCTest
import Sio

class PreludeTests: XCTestCase {
	func testId() {
		XCTAssert(id(1) == 1)
		XCTAssert(id("a") == "a")
	}
	
	func testDiscard() {
		XCTAssert(discard(1) == ())
		XCTAssert(discard("a") == ())
	}
	
	func testConst() {
		XCTAssert(const(1)("a") == 1)
		XCTAssert(const(1)(70) == 1)
	}
}
