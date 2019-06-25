//
//  sioTests.swift
//  sio
//
//  Created by José Manuel Sánchez on 19/5/19.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import XCTest
import sio

class sioTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //// XCTAssertEqual(sio().text, "Hello, World!")
    }
	
	func testOther() {
		let finish = expectation(description: "finish tasks")
		
		let long = Array(1...800).forEach { item in
			environment(Console.self)
				.flatMap { console in
					console.printLine("long \(item)").require(Console.self)
				}
				.scheduleOn(.global())
			}
			//.map(const(1000))
			.provide(Console.default)
		
		//let long = UIO<Int>.init { (_, _, resolve) in
		//	(1...10).forEach { Swift.print("\($0)") }
		//
		//	print("-------------")
		//
		//	resolve(1000)
		//}
		
		let long2 = UIO<[Int]>.init { (_, _, resolve) in
			(0...800).forEach { Swift.print("\($0)") }
			
			print("-------------")
			
			resolve(Array(0...80))
		}
		
		let task = zip(
			long,
			long2
			)
			.scheduleOn(DispatchQueue.global())
		
		task.fork(absurd, { a in
			print("Success \(a)")
			
			finish.fulfill()
		})
		
		print("before cancel zip")
		//DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
		//	long.cancel()
		//}
		
		//task.cancel()
		
		print("after cancel zip")
		
		waitForExpectations(timeout: 5, handler: nil)
	}
	
	func testFlip() {
		let finish = expectation(description: "finish tasks")

		SIO<Void, String, Int>.rejected("ok").flip().fork({ _ in
			XCTFail()
		}, { value in
			XCTAssert(value == "ok")
			finish.fulfill()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testFlipInverse() {
		let finish = expectation(description: "finish tasks")
		
		SIO<Void, String, Int>.of(1).flip().fork({ value in
			XCTAssert(value == 1)
			finish.fulfill()
		}, { _ in
			XCTFail()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
