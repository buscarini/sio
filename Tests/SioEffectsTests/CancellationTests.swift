//
//  CancellationTests.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 16/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import XCTest
import Sio
import SioEffects

class CancellationTests: XCTestCase {
	let scheduler = TestScheduler()
	
	func testNoCancellation() {
		var lastValue: Int = 0
		var task: UIO<Void>?
		
		let finish = expectation(description: "finish")
		
		func long() -> UIO<Void> {
			return Array(1...800).forEach { item in
				IO<Never, Int>.init { _ in
						.right(item)
					}
					.flatMap { int in
						return IO<Never, Int> { _ in
							lastValue = int
							return .right(int)
						}
				}.scheduleOn(.global()).forkOn(.global())
			}
			.map(const(()))
		}
		
		task = long().scheduleOn(DispatchQueue.global())
		
		task?
		.fork(absurd, { a in
			finish.fulfill()
		})
		
		waitForExpectations(timeout: 10, handler: nil)
	}

	func testCancellation() {
		var lastValue: Int = 0
		var task: UIO<Void>?

		let finish = expectation(description: "cancel")

		func long() -> UIO<Void> {
			Array(1...800).forEach { item in
				IO<Never, Int>.init { _ in
					.right(item)
				}
				.flatMap { int in
					IO<Never, Int> { _ in
						let tmp = task?.cancelled
						XCTAssert(tmp == false)
						lastValue = int
						return .right(int)
					}
				}
				.scheduleOn(.global())
			}
			.map(const(()))
		}

		task = long().scheduleOn(DispatchQueue.global())

		task?
		.fork(absurd, { a in
			XCTFail()
		})

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			task?.cancel()
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			XCTAssert(lastValue < 800)
			finish.fulfill()
		}

		waitForExpectations(timeout: 10, handler: nil)
	}
	
	/*func testCancellationMultiple() {
		let globalScheduler = TestScheduler()
		
		var cancelled = false

		let finish = expectation(description: "Finish after cancelling")
		finish.isInverted = true
		
		let first = Array(1...800).forEach { item in
			accessM(Console.self) { console -> SIO<Console, Never, Void> in
					XCTAssert(cancelled == false)
					return console.printLine("long \(item)").require(Console.self)
				}
				.scheduleOn(globalScheduler)
			}
			.provide(Console.default)
		
		let second = UIO<[Int]>.init { (_, _, resolve) in
			(0...800).forEach { _ in }
			
			resolve(Array(0...80))
		}
		
		let task = zip(
			first,
			second,
			globalScheduler
		)
		
		task.fork(absurd, { a in
			finish.fulfill()
		})
		
		globalScheduler.advance()
		
		print("before cancel")
		task.cancel()
		cancelled = true
		print("after cancel")
		
		globalScheduler.advance()
		
		waitForExpectations(timeout: 10, handler: nil)
	}*/
	
	func testCancellationProfunctor() {
		let finish = expectation(description: "finish")
		finish.isInverted = true
		
		let task = UIO<Int>.of(1)
			.scheduleOn(.global())
			.delay(0.1, scheduler)
		
		task
		.fork(absurd, { a in
			XCTFail()
		})
		
		task.cancel()
		
		scheduler.advance(1)
		
		waitForExpectations(timeout: 0.1, handler: nil)
	}
	
	func testCancellationOr() {
		let finish = expectation(description: "finish")
		
		let left = IO<Void, Int>.rejected(())
		let right = IO<Void,Int>.of(1).scheduleOn(.global()).delay(0.1)
		
		let task = or(left, right)
			
		task
		.fork(
			{ _ in
				XCTFail()
			},
			{ a in
				XCTFail()
			}
		)
		
		task.cancel()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
			finish.fulfill()
		}
		
		waitForExpectations(timeout: 2, handler: nil)
	}
	
	func testCancelSync() {
		let finish = expectation(description: "finish")
		
		let task = UIO.sync {
			.right(1)
		}
		.scheduleOn(.global())
		
		task.cancel()
			
		task
		.fork(
			{ _ in
			},
			{ a in
				XCTFail()
			}
		)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
			finish.fulfill()
		}
		
		waitForExpectations(timeout: 2, handler: nil)
	}
}
