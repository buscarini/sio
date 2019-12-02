//
//  OptionalTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 01/12/2019.
//

import XCTest
import Sio

class OptionalTests: XCTestCase {
	func testFromValue() {
		let expectation = self.expectation(description: "task succeeded")
		
		IO<String, Int>.from(3, default: 1)
			.fork({ _ in
				XCTFail()
			}) { value in
				XCTAssert(value == 3)
				expectation.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testFromNil() {
		let expectation = self.expectation(description: "task succeeded")
		
		IO<String, Int>.from(nil, default: 1)
			.fork({ _ in
				XCTFail()
			}) { value in
				XCTAssert(value == 1)
				expectation.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testOptional() {
		let expectation = self.expectation(description: "task succeeded")
		
		IO<String, Int>.of(1)
			.optional()
			.fork(absurd) { value in
				XCTAssert(value == 1)
				expectation.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testOptionalNil() {
		let expectation = self.expectation(description: "task succeeded")
		
		IO<String, Int>.rejected("a")
			.optional()
			.fork(absurd) { value in
				XCTAssert(value == nil)
				expectation.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testFromFNil() {
		let expectation = self.expectation(description: "task succeeded")
		
		SIO<Int, Void, Int>.from({ _ in
				nil
			})
			.provide(1)
			.fork({ value in
				XCTAssert(value == ())
				expectation.fulfill()
			}) { _ in
				XCTFail()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testFromFValue() {
		let expectation = self.expectation(description: "task succeeded")
		
		SIO<Int, Void, Int>.from({ $0 * 2 })
			.provide(2)
			.fork({ _ in
				XCTFail()
			}) { value in
				XCTAssert(value == 4)
				expectation.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testMap2() {
		let expectation = self.expectation(description: "task succeeded")
		
		let opt: Int? = 1
		
		let value = UIO<Int?>.of(opt).map2 { $0*2 }
		value.fork(absurd) { value in
			XCTAssert(value == 2)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
