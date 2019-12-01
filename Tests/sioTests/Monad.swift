//
//  Monad.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Sio

class Monad: XCTestCase {
	func exampleError() -> Error {
		return NSError(domain: "tests", code: 1, userInfo: nil)
	}
	
    func testFlatMap() {
		let expectation = self.expectation(description: "task chained")
		
		IO<Never, String>.of("blah")
			.flatMap({ string in
				return SIO.of(string.count)
			})
			.run { value in
				XCTAssert(value == 4)
				expectation.fulfill()
			}
	
	
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testFlatMapFail() {
		let expectation = self.expectation(description: "task not chained")
		
		IO<Error, String>.rejected(self.exampleError())
			.flatMap({ string in
				return Task.of(string.count)
			})
			.fork((), { error in
				expectation.fulfill()
			},
			{ value in
				XCTFail()
			})
	
	
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testDefault() {
		let expectation = self.expectation(description: "task chained")
		
		IO<String, Int>.rejected("blah")
			.default(1)
			.fork({ _ in
				XCTFail()
			}) { value in
				XCTAssert(value == 1)
				expectation.fulfill()
			}
	
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
}
