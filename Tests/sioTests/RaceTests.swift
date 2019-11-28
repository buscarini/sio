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
		
		let left = UIO.of(1).scheduleOn(DispatchQueue.init(label: "left")).delay(0.5, DispatchQueue.main)
		let right = UIO.of(2).scheduleOn(DispatchQueue.init(label: "right")).delay(5, DispatchQueue.main)
		
		race(left, right).run { value in
			XCTAssert(value == 1)
			
			finish.fulfill()
		}
		
		wait(for: [finish], timeout: 5)
	}
	
	func testRaceOneFails() {
		let finish = expectation(description: "finish")
		
		let left = SIO<Void, String, Int>.rejected("err").scheduleOn(DispatchQueue.init(label: "left")).delay(0.5, DispatchQueue.main)
		let right = SIO<Void, String, Int>.of(2).scheduleOn(DispatchQueue.init(label: "right")).delay(1, DispatchQueue.main)
		
		race(left, right).fork({ e in
			XCTFail()
		}, { value in
			XCTAssert(value == 2)
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 10)
	}
}
