import Foundation
import XCTest

import CombineSchedulers

import Sio

class SchedulerTests: XCTestCase {
	func testNotAdvance() {
		let inverted = expectation(description: "Don't fulfill")
		inverted.isInverted = true
		
		let scheduler = DispatchQueue.test
		scheduler.run {
			inverted.fulfill()
		}
		
		waitForExpectations(timeout: 0.1, handler: nil)
	}
	
	func testAdvance() {
		let finish = expectation(description: "Fulfill")
		
		let scheduler = DispatchQueue.test
		scheduler.run {
			finish.fulfill()
		}
		scheduler.advance()
		
		waitForExpectations(timeout: 0.1, handler: nil)
	}
	
	func testAfterNotYet() {
		let inverted = expectation(description: "Don't fulfill")
		inverted.isInverted = true

		let scheduler = DispatchQueue.test
		scheduler.run(after: 3) {
			inverted.fulfill()
		}
		
		scheduler.advance(by: .seconds(1.0))
		
		waitForExpectations(timeout: 0.1, handler: nil)
	}
	
	func testAfterRun() {
		let finish = expectation(description: "Fulfill")

		let scheduler = DispatchQueue.test
		scheduler.run(after: 3) {
			finish.fulfill()
		}
		scheduler.advance(by: .seconds(4.0))
		
		// Check that the work is not done more than once
		scheduler.advance(by: .seconds(5.0))
		scheduler.advance(by: .seconds(6.0))
		
		waitForExpectations(timeout: 0.1, handler: nil)
	}
}
