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
	
	func testNoCancellation() {
		var lastValue: Int = 0
		var task: UIO<Void>?
		
		let finish = expectation(description: "finish")
		
		func long() -> UIO<Void> {
			return Array(1...800).forEach { item in
				IO<Never, Int>.init { _ in
					print(item)
					return .right(item)
					}
					.flatMap { int in
						return IO<Never, Int> { _ in
							lastValue = int
							return .right(int)
						}
				}
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
			return Array(1...800).forEach { item in
				IO<Never, Int>.init { _ in
					return .right(item)
				}
				.flatMap { int in
					return IO<Never, Int> { _ in
						let tmp = task?.cancelled
						XCTAssert(tmp == false)
						lastValue = int
						return .right(int)
					}
				}
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
	
	func testCancellationMultiple() {
		var cancelled = false

		let finish = expectation(description: "Finish after cancelling")
		finish.isInverted = true
		
		let first = Array(1...800).forEach { item in
			accessM(Console.self) { console -> SIO<Console, Never, Void> in
					XCTAssert(cancelled == false)
					print(cancelled)
					return console.printLine("long \(item)").require(Console.self)
				}
				.scheduleOn(.global())
			}
			.provide(Console.default)
//			.provide(Console.mock(""))
		
		let second = UIO<[Int]>.init { (_, _, resolve) in
			(0...800).forEach { Swift.print("\($0)") }
			
			print("-------------")
			
			resolve(Array(0...80))
		}
		
		let task = zip(
			first,
			second
		)
		.scheduleOn(DispatchQueue.global())
		
		
		task.fork(absurd, { a in
			finish.fulfill()
		})
		
		print("before cancel")
		task.cancel()
		cancelled = true
		print("after cancel")
		
		waitForExpectations(timeout: 10, handler: nil)
	}
}
