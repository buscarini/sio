//
//  SioFoldTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 01/12/2019.
//

import Foundation
import XCTest
import Sio

class SioFoldTests: XCTestCase {
	func testFoldNil() {
		let expectation = self.expectation(description: "task succeeded")
		
		IO<String, Int>.rejected("a")
			.fold({ _ in 1 }, { $0*2 })
			.fork({ _ in
				XCTFail()
			}) { value in
				XCTAssert(value == 1)
				expectation.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testFoldValue() {
		let expectation = self.expectation(description: "task succeeded")
		
		IO<String, Int>.of(1)
			.fold({ _ in 1 }, { $0*2 })
			.fork({ _ in
				XCTFail()
			}) { value in
				XCTAssert(value == 2)
				expectation.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testFoldMNil() {
		let expectation = self.expectation(description: "task succeeded")
		
		IO<String, Int>.rejected("a")
			.foldM({ _ in .of(1) }, { .of($0*2) })
			.fork({ _ in
				XCTFail()
			}) { value in
				XCTAssert(value == 1)
				expectation.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testFoldMValue() {
		let expectation = self.expectation(description: "task succeeded")
		
		IO<String, Int>.of(1)
			.foldM({ _ in .of(1) }, { .of($0*2) })
			.fork({ _ in
				XCTFail()
			}) { value in
				XCTAssert(value == 2)
				expectation.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testFoldMNilRejected() {
		let expectation = self.expectation(description: "task succeeded")
		
		let io: IO<String, Int> = IO<String, Int>.rejected("a")
			.foldM({ _ in .rejected("b") }, { _ in .rejected("c") })
			
		io
			.fork({ value in
				XCTAssert(value == "b")
				expectation.fulfill()
			}) { value in
				XCTFail()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testFoldMValueRejected() {
		let expectation = self.expectation(description: "task succeeded")
		
		let io: IO<String, Int> = IO<String, Int>.of(1)
			.foldM({ _ in .rejected("b") }, { _ in .rejected("c") })
			
		io
			.fork({ value in
				XCTAssert(value == "c")
				expectation.fulfill()
			}) { value in
				XCTFail()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}

