//
//  RaceTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 03/07/2019.
//

import Foundation
import Foundation
import XCTest
import Sio

class RaceTests: XCTestCase {
	func testRace() {
		let finish = expectation(description: "finish")
		
		let left = UIO.of(1).scheduleOn(DispatchQueue.init(label: "left")).delay(0.5, QueueScheduler.main)
		let right = UIO.of(2).scheduleOn(DispatchQueue.init(label: "right")).delay(5, QueueScheduler.main)
		
		race(left, right).run { value in
			XCTAssert(value == 1)
			
			finish.fulfill()
		}
		
		wait(for: [finish], timeout: 5)
	}
	
	func testRaceOneFails() {
		let finish = expectation(description: "finish")
		
		let left = SIO<Void, String, Int>.rejected("err").scheduleOn(DispatchQueue.init(label: "left")).delay(0.5, QueueScheduler.main)
		let right = SIO<Void, String, Int>.of(2).scheduleOn(DispatchQueue.init(label: "right")).delay(1, QueueScheduler.main)
		
		race(left, right).fork({ e in
			XCTFail()
		}, { value in
			XCTAssert(value == 2)
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 10)
	}
	
	func testRaceCancel1() {
		let finish = expectation(description: "finish")
		
		let left = UIO.of(1).scheduleOn(DispatchQueue.init(label: "left")).delay(0.5, QueueScheduler.main)
		let right = UIO.of(2).scheduleOn(DispatchQueue.init(label: "right")).delay(2, QueueScheduler.main)
		
		race(left, right).run { value in
			XCTAssert(value == 2)
			
			finish.fulfill()
		}
		
		left.cancel()
		
		wait(for: [finish], timeout: 5)
	}
	
	func testRaceCancel2() {
		let finish = expectation(description: "finish")
		
		let left = UIO.of(1).scheduleOn(DispatchQueue.init(label: "left")).delay(2, QueueScheduler.main)
		let right = UIO.of(2).scheduleOn(DispatchQueue.init(label: "right")).delay(0.5, QueueScheduler.main)
		
		race(left, right).run { value in
			XCTAssert(value == 1)
			
			finish.fulfill()
		}
		
		right.cancel()
		
		wait(for: [finish], timeout: 5)
	}
	
	func testRaceCancel() {
		let finish = expectation(description: "finish")
		
		let left = UIO.of(1).scheduleOn(DispatchQueue.init(label: "left")).delay(2, QueueScheduler.main)
		let right = UIO.of(2).scheduleOn(DispatchQueue.init(label: "right")).delay(0.5, QueueScheduler.main)
		
		let raced = race(left, right)
			.scheduleOn(.global())
			.delay(0.1)
			.onCancellation(SIO.effectMain {
				finish.fulfill()
			})
			
		raced
			.run { value in
				XCTFail()
			}
		
		raced.cancel()
		
		wait(for: [finish], timeout: 5)
	}
}
