//
//  sioTests.swift
//  sio
//
//  Created by José Manuel Sánchez on 19/5/19.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import XCTest
import Sio

class sioTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //// XCTAssertEqual(sio().text, "Hello, World!")
    }
	
	func testFlip() {
		let finish = expectation(description: "finish tasks")

		SIO<Void, String, Int>.rejected("ok").flip().fork({ _ in
			XCTFail()
		}, { value in
			XCTAssert(value == "ok")
			finish.fulfill()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testFlipInverse() {
		let finish = expectation(description: "finish tasks")
		
		SIO<Void, String, Int>.of(1).flip().fork({ value in
			XCTAssert(value == 1)
			finish.fulfill()
		}, { _ in
			XCTFail()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testEitherLeft() {
		let finish = expectation(description: "finish tasks")
		
		IO.from(Either<String, Int>.left("ok")).fork({ value in
			XCTAssert(value == "ok")
			finish.fulfill()
		}) { _ in
			XCTFail()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testEitherRight() {
		let finish = expectation(description: "finish tasks")

		
		IO.from(Either<String, Int>.right(1)).fork({ _ in
			XCTFail()
		}) { value in
			XCTAssert(value == 1)
			finish.fulfill()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
