//
//  Monad.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Sio

class MonadTests: XCTestCase {
	let scheduler = TestScheduler()
	
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
	
	func testFlatMapSIO() {
		let expectation = self.expectation(description: "task chained")
		
		let stringLen = SIO<String, Never, Int>.sync { string in
			.right(string.count)
		}
		
		IO<Never, String>.of("blah")
			.flatMap(stringLen)
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
			}) { value in
				XCTAssert(value == 1)
				expectation.fulfill()
		}
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testForever() {
		let repeated = self.expectation(description: "repeated")
		repeated.expectedFulfillmentCount = 3
		
		let task = IO.effectMain {
			repeated.fulfill()
		}
		.forever()
		.delay(1, scheduler)
			
		task.runForget()
		
		scheduler.advance(1)
		scheduler.advance(1)
		scheduler.advance(1)
		
		task.cancel()
		
		repeated.isInverted = true
		scheduler.advance(1)
		
		self.waitForExpectations(timeout: 1, handler: nil)
	}
}
