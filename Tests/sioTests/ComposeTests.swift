//
//  ComposeTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 05/12/2019.
//

import Foundation
import XCTest
import Sio

class ComposeTests: XCTestCase {
	func uppercase(_ left: String) -> String {
		left.uppercased()
	}
	
	func bang(_ left: String) -> String {
		left + "!"
	}
	
	func testCompose() {
		XCTAssert(compose(uppercase, bang)("hello") == "HELLO!")
	}
	
	func testCompose2() {
		XCTAssert(compose(uppercase, bang, bang)("hello") == "HELLO!!")
	}
	
	func testCompose3() {
		XCTAssert(compose(uppercase, bang, bang, bang)("hello") == "HELLO!!!")
	}
	
	func testCompose4() {
		XCTAssert(compose(uppercase, bang, bang, bang, bang)("hello") == "HELLO!!!!")
	}
	
	func testCompose5() {
		XCTAssert(compose(uppercase, bang, bang, bang, bang, bang)("hello") == "HELLO!!!!!")
	}
	
	func uppercaseT(_ left: String) throws -> String {
		left.uppercased()
	}
	
	func bangT(_ left: String) throws -> String {
		left + "!"
	}
	
	func testComposeThrow() {
		XCTAssert(try! compose(uppercaseT, bangT)("hello") == "HELLO!")
	}
	
	func testCompose2Throw() {
		XCTAssert(try! compose(uppercaseT, bangT, bangT)("hello") == "HELLO!!")
	}
	
	func testCompose3Throw() {
		XCTAssert(try! compose(uppercaseT, bangT, bangT, bangT)("hello") == "HELLO!!!")
	}
	
	func testCompose4Throw() {
		XCTAssert(try! compose(uppercaseT, bangT, bangT, bangT, bangT)("hello") == "HELLO!!!!")
	}
	
	func testCompose5Throw() {
		XCTAssert(try! compose(uppercaseT, bangT, bangT, bangT, bangT, bangT)("hello") == "HELLO!!!!!")
	}
}
