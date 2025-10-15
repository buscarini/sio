import Foundation
import XCTest

import CombineSchedulers

import Sio

class RaceTests: XCTestCase {
	let scheduler = DispatchQueue.test
	
	func testRace() {
		let finish = expectation(description: "finish")
		
		let left = UIO.of(1).delay(0.5, scheduler)
		let right = UIO.of(2).delay(5, scheduler)
		
		race(left, right).run { value in
			XCTAssert(value == 1)
			
			finish.fulfill()
		}
		
		scheduler.advance(by: .seconds(0.5))
		scheduler.advance(by: .seconds(6.0))

		waitForExpectations(timeout: 5, handler: nil)
	}
	
	func testRaceOneFails() {
		let finish = expectation(description: "finish")
		
		let left = SIO<Void, String, Int>
			.rejected("err")
			.delay(0.5, scheduler)
		let right = SIO<Void, String, Int>.of(2)
			.delay(1, scheduler)
		
		race(left, right).fork({ e in
			XCTFail()
		}, { value in
			XCTAssert(value == 2)
			finish.fulfill()
		})
		
		scheduler.advance(by: .seconds(0.5))
		scheduler.advance(by: .seconds(1.0))
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testRaceTwoFail() {
		let finish = expectation(description: "finish")
		
		let left = SIO<Void, String, Int>
			.rejected("err")
			.delay(0.5, scheduler)
		let right = SIO<Void, String, Int>
			.rejected("err2")
			.delay(1, scheduler)
		
		race(left, right).fork({ e in
			XCTAssert(e == "err")
			finish.fulfill()
		}, { value in
			XCTFail()
		})
		
		scheduler.advance(by: .seconds(0.5))
		scheduler.advance(by: .seconds(1.0))

		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testRaceCancel1() {
		let finish = expectation(description: "finish")
		
		let left = UIO.of(1).delay(0.5, scheduler)
		let right = UIO.of(2).delay(2, scheduler)
		
		race(left, right).run { value in
			XCTAssert(value == 2)
			
			finish.fulfill()
		}
		
		left.cancel()
		
		scheduler.advance(by: .seconds(0.5))
		scheduler.advance(by: .seconds(2.0))

		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testRaceCancel2() {
		let finish = expectation(description: "finish")
		
		let left = UIO.of(1).delay(2, scheduler)
		let right = UIO.of(2).delay(0.5, scheduler)
		
		race(left, right).run { value in
			XCTAssert(value == 1)
			
			finish.fulfill()
		}
		
		right.cancel()
		
		scheduler.advance(by: .seconds(0.5))
		scheduler.advance(by: .seconds(2.0))

		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testRaceCancel() {
		let finish = expectation(description: "finish")
		
		let left = UIO.of(1).delay(2, scheduler)
		let right = UIO.of(2).delay(0.5, scheduler)
		
		let raced = race(left, right)
			.delay(0.1, scheduler)
			.onCancellation(SIO.effectMain {
				finish.fulfill()
			})
			
		raced
			.run { value in
				XCTFail()
			}
		
		raced.cancel()
		
		scheduler.advance(by: .seconds(0.1))
		scheduler.advance(by: .seconds(1.0))
		scheduler.advance(by: .seconds(2.0))

		waitForExpectations(timeout: 1, handler: nil)
	}
}
