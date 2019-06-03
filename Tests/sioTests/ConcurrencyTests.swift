//
//  ConcurrencyTests.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 23/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import XCTest
import sio

class ConcurrencyTests: XCTestCase {
	func testForEach() {
		let finish = expectation(description: "finish")
		
		let values = Array(1...10000)

		
		let task = values.forEach {
			UIO<Int>.of($0)
		}
		
		task.run((), { result in
			XCTAssert(result == values)
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 1)
	}
	
	func testForEachGlobalQueueDebug() {
		let finish = expectation(description: "finish")
		
		let values = Array(1...100)
		
		let task = values.forEach {
			UIO<Int>.of($0)
			}
			.scheduleOn(DispatchQueue.global())
		
		task.forkMain(absurd, { result in
			XCTAssert(result == values)
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 1)
	}
	
	func testForEachGlobalQueue() {
		let finish = expectation(description: "finish")
		
		let values = Array(1...100)
		
		let task = values.forEach {
			UIO<Int>.of($0)
		}
		.scheduleOn(DispatchQueue.global())
		
		task.forkMain(absurd, { result in
			XCTAssert(result == values)
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 1)
	}
	
	func testForEachGlobalQueueMultiple() {
		let finish = expectation(description: "finish")

		let values = Array(1...1000)

		let task = values.forEach {
			UIO<Int>.of($0).scheduleOn(DispatchQueue.global())
		}

		task.forkMain(absurd, { result in
			XCTAssert(result == values)
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 2)
	}

	func testTraverseIsParallel() {
		let finish = expectation(description: "finish")

		let values = Array(1...100)

		let task = values.traverse {
			UIO<Int>.of($0).scheduleOn(DispatchQueue.init(label: "\($0)")).delay(0.5)
		}
		.scheduleOn(DispatchQueue.global())
		
		task.run((), { result in
			XCTAssert(result == values)
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
		
		wait(for: [finish], timeout: 5)
	}
	
//	func testForEachPerformance() {
//		measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
//
//			startMeasuring()
//
//			let values = Array(1...1000)
//
//			let task = values.forEach {
//				UIO<Int>.of($0).scheduleOn(DispatchQueue.global())
//			}
//
//			task.forkMain(absurd, { result in
//				self.stopMeasuring()
//			})
//
//		}
//	}
}
