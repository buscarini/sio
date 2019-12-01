//
//  Arrays.swift
//  IO
//
//  Created by José Manuel Sánchez Peñarroja on 10/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Sio

class Arrays: XCTestCase {
	func testMap2() {
		let expectation = self.expectation(description: "task succeeded")

		let value = UIO<[Int]>.of([1, 2, 3]).map2 { $0*2 }
		value.fork(absurd) { values in
			XCTAssert(values == [2, 4, 6])
			expectation.fulfill()
		}

		waitForExpectations(timeout: 1, handler: nil)
	}
	
	
	func exampleError() -> Error {
		return NSError(domain: "tests", code: 1, userInfo: nil)
	}
	
	func testTraverse() {
		
		let expectation = self.expectation(description: "task succeeded")
		
		[1, 2, 3].traverse { IO<Never, Int>.of($0) }
			.fork({ error in
				XCTFail()
			},
					{ values in
						XCTAssert(values.count == 3)
						XCTAssert(values[0] == 1)
						XCTAssert(values[1] == 2)
						XCTAssert(values[2] == 3)
						expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testParallel() {
		
		let expectation = self.expectation(description: "task succeeded")
		
		parallel([ IO<Error, Int>.of(1), IO.of(2), IO.of(3)].map(delayed(1)))
			.fork((), { error in
				XCTFail()
			},
					{ values in
						XCTAssert(values.count == 3)
						XCTAssert(values[0] == 1)
						XCTAssert(values[1] == 2)
						XCTAssert(values[2] == 3)
						expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.1, handler: nil)
	}
	
	func testSequence() {
		
		let expectation = self.expectation(description: "task succeeded")
		
		var value = 0
		
		let first = IO<Error, Int>({ (_, reject, resolve) in
			guard value == 0 else {
				reject(self.exampleError())
				return
			}
			
			value += 1
			print("\(Date())")
			
			resolve(value)
		})
		
		let second = IO<Error, Int>({ (_, reject, resolve) in
			guard value == 1 else {
				reject(self.exampleError())
				return
			}
			
			value += 1
			print("\(Date())")
			
			resolve(value)
		})
		
		let third = IO<Error, Int>({ (_, reject, resolve) in
			guard value == 2 else {
				reject(self.exampleError())
				return
			}
			
			value += 1
			print("\(Date())")
			
			resolve(value)
		})
		
		let now = Date()
		
		sequence([ first, second, third ].map(delayed(1)))
			.fork({ error in
				XCTFail()
			},
					{ values in
						print("\(now.timeIntervalSinceNow)")
						XCTAssert(-now.timeIntervalSinceNow > 3.0)
						
						XCTAssert(values.count == 3)
						XCTAssert(values[0] == 1)
						XCTAssert(values[1] == 2)
						XCTAssert(values[2] == 3)
						expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 4.1, handler: nil)
	}
}
