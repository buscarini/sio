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
	func testCancellation() {
		var cancelled = false
		
		let finish = expectation(description: "cancel")
		
		func long(_ string: String) -> UIO<Void> {
			return Array(1...800).forEach { item in
			environment(Console.self)
				.flatMap { console -> SIO<Console, Never, Void> in
					
					return console.printLine("\(string) \(item)").require(Console.self)
				}
				.flatMap { _ in
					return SIO<Console, Never, Void> { _ in
						XCTAssert(cancelled == false)
						return .right(())
					}
				}
				.scheduleOn(.global())
			}
			.provide(Console.default)
			.map(const(()))
		}
		
		let task = long("long")
		
//		task
//		.scheduleOn(DispatchQueue.global())
		
		task
			.scheduleOn(DispatchQueue.global())
			.fork(absurd, { a in
			XCTFail()
		})
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			task.cancel()
			cancelled = true
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			finish.fulfill()
		}
		
		waitForExpectations(timeout: 8, handler: nil)
	}
}
