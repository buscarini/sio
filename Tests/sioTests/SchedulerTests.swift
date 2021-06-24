//
//  SchedulerTests.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 01/06/2020.
//

import Foundation
import XCTest
import Sio

class SchedulerTests: XCTestCase {
	func testNotAdvance() {
		let inverted = expectation(description: "Don't fulfill")
		inverted.isInverted = true
		
		let scheduler = TestScheduler()
		scheduler.run {
			inverted.fulfill()
		}
		
		waitForExpectations(timeout: 0.1, handler: nil)
	}
	
	func testAdvance() {
		let finish = expectation(description: "Fulfill")
		
		let scheduler = TestScheduler()
		scheduler.run {
			finish.fulfill()
		}
		scheduler.advance()
		
		waitForExpectations(timeout: 0.1, handler: nil)
	}
	
	func testAfterNotYet() {
		let inverted = expectation(description: "Don't fulfill")
		inverted.isInverted = true

		let scheduler = TestScheduler()
		scheduler.runAfter(after: 3) {
			inverted.fulfill()
		}
		scheduler.advance(1)
		
		waitForExpectations(timeout: 0.1, handler: nil)
	}
	
	func testAfterRun() {
		let finish = expectation(description: "Fulfill")

		let scheduler = TestScheduler()
		scheduler.runAfter(after: 3) {
			finish.fulfill()
		}
		scheduler.advance(4)
		
		 // Check that the work is not done more than once
		scheduler.advance(5)
		scheduler.advance(6)
		
		waitForExpectations(timeout: 0.1, handler: nil)
	}
}
