//
//  CancellationTests.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 16/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import XCTest
import sio

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
					print(item)
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
}