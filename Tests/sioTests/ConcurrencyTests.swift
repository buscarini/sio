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
	func testZip() {
		let finish = expectation(description: "finish")
		
		let values = Array(1...100)
		
		let left = values.forEach {
			UIO<Int>.of($0)
		}
		
		let right = values.forEach {
			UIO<Int>.of($0)
		}
		
		zip(
			left,
			right
		)
		.scheduleOn(DispatchQueue.global())
		.run((), { result in
			XCTAssert(result.0 == values)
			XCTAssert(result.1 == values)
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 1)
	}
	
	func testZipStackOverflow() {
		let finish = expectation(description: "finish")
		
		let values = Array(1...900)
		
		let left = values.forEach {
			UIO<Int>.of($0)
		}
		
		let right = values.forEach {
			UIO<Int>.of($0)
		}
		
		zip(
			left,
			right
			)
			.scheduleOn(DispatchQueue.global())
			.run((), { result in
				XCTAssert(result.0 == values)
				XCTAssert(result.1 == values)
				finish.fulfill()
			})
		
		wait(for: [finish], timeout: 1)
	}
	
	func testForEach() {
		let finish = expectation(description: "finish")
		
		let values = Array(1...10000)

		
		let task = values.forEach {
			UIO.of($0)
		}
		
		task.fork((), { _ in }, { result in
			XCTAssert(result == values)
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 10)
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
	
	func testCancel() {
		let finish = expectation(description: "finish")
		
		
		let task = UIO.of(1).scheduleOn(DispatchQueue.global())
		
		task.cancel()
		
		task.fork(absurd, { _ in
			XCTFail()
		})
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			finish.fulfill()
		}
		
		wait(for: [finish], timeout: 5)
	}
	
	func testCancelAfterFork() {
		let finish = expectation(description: "finish")
		
		
		let task = UIO.of(1).scheduleOn(DispatchQueue.global())
		
		task.fork(absurd, { _ in
			XCTFail()
		})
		
		task.cancel()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			finish.fulfill()
		}
		
		wait(for: [finish], timeout: 5)
	}
	
	func testCancelZip() {
		let finish = expectation(description: "finish")
		
		let left = UIO.of(1).scheduleOn(DispatchQueue.global())
		let right = UIO.of(2).scheduleOn(DispatchQueue.global())
		
		let task = zip(left, right)
			
		task
			.fork(absurd, { values in
				print(values)
				XCTFail()
			})
		
		task.cancel()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			finish.fulfill()
		}
		
		wait(for: [finish], timeout: 5)
	}
	
	func testCancelZipLeft() {
		let finish = expectation(description: "finish")
		
		let left = UIO.of(1).scheduleOn(DispatchQueue.global())
		let right = UIO.of(2).scheduleOn(DispatchQueue.global())
		
		left.cancel()
		
		zip(left, right)
		.fork(absurd, { values in
			print(values)
			XCTFail()
		})
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			finish.fulfill()
		}
		
		wait(for: [finish], timeout: 5)
	}
	
	func testForEachPerformance() {
		
		measureMetrics([.wallClockTime], automaticallyStartMeasuring: true) {
			let finish = expectation(description: "finish")

			let values = Array(1...10000)

			let task = values.forEach {
				UIO<Int>.of($0)
			}.scheduleOn(DispatchQueue.global())

			task.forkMain(absurd, { result in
				finish.fulfill()
			})
			
			waitForExpectations(timeout: 5, handler: { _ in
				self.stopMeasuring()
			})
		}
		
	}
}
