//
//  Functor.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import sio

class Functor: XCTestCase {
    func exampleError() -> Error {
		return NSError(domain: "tests", code: 1, userInfo: nil)
	}
	
	func testMap() {
		let expectation = self.expectation(description: "task mapped")
		
		IO<Error, String>.of("blah")
			.map({ string in
				return string.count
			})
			.fork((), { error in
				XCTFail()
			},
			{ value in
				XCTAssert(value == 4)
				expectation.fulfill()
			})
	
	
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testMapFail() {
		let expectation = self.expectation(description: "task not mapped")
		
		IO<Error, String>.rejected(self.exampleError())
			.map({ string in
				return string.count
			})
			.fork((), { error in
				expectation.fulfill()
			},
			{ value in
				XCTFail()
			})
	
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
}
