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
		func int(_ a: Int) -> Int {
			a
		}
		
		func string(_ a: String) -> String {
			a
		}
		
		XCTAssert(discard(int)(1) == ())
		XCTAssert(discard(string)("a") == ())
	}
	
	func testConst() {
		XCTAssert(const(1)("a") == 1)
		XCTAssert(const(1)(70) == 1)
	}
}
