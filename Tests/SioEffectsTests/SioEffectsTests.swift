//
//  SIOEffectsTests.swift
//  SIOValueStore
//
//  Created by José Manuel Sánchez on 19/5/19.
//  Copyright © 2019 SIOValueStoreTests. All rights reserved.
//

import Foundation
import XCTest

import Sio
import SioEffects

class SIOEffectsTests: XCTestCase {
	/*func testOther() {
		let finish = expectation(description: "finish tasks")
		
		let long = Array(1...800).forEach { item in
			return accessM(Console.self) { console in
				console.printLine("long \(item)").require(Console.self)
			}.scheduleOn(.global())
			.provide(Console.default)
		}
		
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
		
		waitForExpectations(timeout: 15, handler: nil)
	}*/
	
	func testTraverse() {
		let values = Array(1...10)
		
		let task = values.traverse { index in
			Console.defaultPrintLine("\(index)")
				.flatMap {
					UIO<Int>.of(index)
			}
		}
		
		task.assert(values, timeout: 1)
	}
}
