//
//  ConcurrencyTests.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 23/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import XCTest
import Sio

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
		
		let values = Array(1...10000)
		
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
		
		let values = Array(1...100_000)

		
		let task = values.forEach {
			UIO.of($0)
		}
		
		task.fork((), { _ in }, { result in
			XCTAssert(result == values)
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 4)
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

		let values = Array(1...100)

		let task = values.forEach {
			UIO<Int>.of($0).scheduleOn(DispatchQueue.global())
		}

		task.forkMain(absurd, { result in
			XCTAssert(result == values)
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 1)
	}

	/*func testTraverseIsParallel() {
		let finish = expectation(description: "finish")

		let values = Array(1...20)

		let task = values.traverse { index -> UIO<Int> in
			let queue = DispatchQueue.init(label: "\(index)", attributes: .concurrent)
			
			return
				Console.defaultPrintLine("\(index)")
				.flatMap {
					UIO<Int>.of(index)
				}
//				.scheduleOn(queue)
				.delay(1, queue)
		}
		.scheduleOn(DispatchQueue.global())
		
		task.run((), { result in
			print(result)
			XCTAssert(result == values)
			finish.fulfill()
		})
		
		waitForExpectations(timeout: 2.0) { _ in
			
		}
	}*/
	
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
	
	func testForEachPerformanceNoSIO() {
		measureMetrics([.wallClockTime], automaticallyStartMeasuring: true) {
			let values = Array(1...100_000)
			
			var last: Int = 0
			values.forEach {
				last = $0
			}
		}		
	}
	
	func testForEachPerformance() {
		measureMetrics([.wallClockTime], automaticallyStartMeasuring: true) {
			let finish = expectation(description: "finish")

			let values = Array(1...100_000)
			
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
	
	func testReduceRegularPerformance() {
		measureMetrics([.wallClockTime], automaticallyStartMeasuring: true) {
			let values = Array(1...100_000)
			_ = values.reduce(0, { res, value in
				res + value
			})
		}
	}
	
	func testFoldMPerformance() {
		measureMetrics([.wallClockTime], automaticallyStartMeasuring: true) {
			let finish = expectation(description: "finish")
			
			let values = Array(1...100_000)
			
			let task: UIO<Int> = values.foldM(0) {
				.of($0 + $1)
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
