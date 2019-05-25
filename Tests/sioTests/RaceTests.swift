//
//  RaceTests.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 23/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import XCTest
import sio

class RaceTests: XCTestCase {
	func testTraverse() {
		let finish = expectation(description: "finish")
		
		let task = Array(1...100).traverse {
			UIO<Int>.of($0).scheduleOn(DispatchQueue.init(label: "\($0)")).delay(0.5)
		}
		
		task.run((), { values in
			XCTAssert(values == Array(1...100))
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 1)
	}
	
	func testRace() {
		let finish = expectation(description: "finish")
		
		let left = UIO.of(1).scheduleOn(DispatchQueue.init(label: "left")).delay(0.5)
		let right = UIO.of(2).scheduleOn(DispatchQueue.init(label: "right")).delay(5)
		
		race(left, right).run { value in
			XCTAssert(value == 1)
			
			finish.fulfill()
		}
		
		wait(for: [finish], timeout: 1)
	}
}
