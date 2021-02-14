//
//  Delay.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Sio

class Delay: XCTestCase {
	let scheduler = TestScheduler()
	
	func exampleError() -> Error {
		return NSError(domain: "tests", code: 1, userInfo: nil)
	}
	
	func testDelay() {
		let expectation = self.expectation(description: "task is delayed")
		
		let task = IO<Error, Int>.of(1)
				
		task.delay(1, scheduler)
			.fork((), { error in
				XCTFail()
			},
			{ value in
				XCTAssert(value == 1)
				expectation.fulfill()
			})
		
		scheduler.advance(1)
		
		self.waitForExpectations(timeout: 2.0, handler: nil)
	}
	
	func testDelayFail() {
		let expectation = self.expectation(description: "task is delayed with failure")
		
		let task = IO<Error, Int>.rejected(self.exampleError())
		
		task.delay(1, scheduler)
			.fork((), { error in
				expectation.fulfill()
			},
			{ value in
				XCTFail()
			})
		
		scheduler.advance(1)
		
		self.waitForExpectations(timeout: 2.0, handler: nil)
	}
	
	func testSleep() {
		let runEffect = self.expectation(description: "immediate effect")
		let delayedContinuation = self.expectation(description: "delayed continuation is not run")
		delayedContinuation.isInverted = true
		
		let task = IO.effect {
			runEffect.fulfill()
		}
		.sleep(1, scheduler)
		.flatMap { _ in
			.effect {
				delayedContinuation.fulfill()
			}
		}
		
		task.run { _ in
			delayedContinuation.fulfill()
		}
		
		scheduler.advance()
		scheduler.advance(0.5)
		
		self.waitForExpectations(timeout: 0.1, handler: nil)
	}
}
