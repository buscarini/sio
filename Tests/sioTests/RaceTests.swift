//
//  RaceTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 03/07/2019.
//

import Foundation
import XCTest
import Sio

class RaceTests: XCTestCase {
	let scheduler = TestScheduler()
	
	func testRace() {
		let finish = expectation(description: "finish")
		
		let left = UIO.of(1).delay(0.5, scheduler)
		let right = UIO.of(2).delay(5, scheduler)
		
		race(left, right).run { value in
			XCTAssert(value == 1)
			
			finish.fulfill()
		}
		
		scheduler.advance(0.5)
		scheduler.advance(6)
		
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
		
		scheduler.advance(0.5)
		scheduler.advance(1)
		
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
		
		scheduler.advance(0.5)
		scheduler.advance(2)
		
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
		
		scheduler.advance(0.5)
		scheduler.advance(2)
		
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
		
		scheduler.advance(0.1)
		scheduler.advance(1)
		scheduler.advance(2)
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
