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
		UIO<[Int]>.of([1, 2, 3]).map2 { $0*2 }
			.assert([ 2, 4, 6 ])
	}
		
	func exampleError() -> Error {
		return NSError(domain: "tests", code: 1, userInfo: nil)
	}
	
	func testTraverseEmpty() {
		[].traverse { IO<Never, Int>.of($0) }
			.assert([])
	}
	
	func testTraverse() {
		[1, 2, 3].traverse { IO<Never, Int>.of($0) }
		.assert([1, 2, 3])
	}
	
	func testConcat() {
		
		concat(
			IO<Int, [Int]>.of([1, 2, 3]),
			IO<Int, [Int]>.of([4, 5, 6])
		)
		.assert([ 1, 2, 3, 4, 5, 6 ])
	}
	
	func testParallel() {
		parallel([ IO<Error, Int>.of(1), IO.of(2), IO.of(3)]
			.map(delayed(0.5)))
			.assert([ 1, 2, 3 ], timeout: 0.61)
	}
	
	func testSequenceEmpty() {
		let ios: [SIO<Void, Void, [Int]>] = []
		sequence(ios)
			.assert([])
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
			
			resolve(value)
		})
		
		let second = IO<Error, Int>({ (_, reject, resolve) in
			guard value == 1 else {
				reject(self.exampleError())
				return
			}
			
			value += 1
			
			resolve(value)
		})
		
		let third = IO<Error, Int>({ (_, reject, resolve) in
			guard value == 2 else {
				reject(self.exampleError())
				return
			}
			
			value += 1
			
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
	
	
	func testPartition() {
		let (even, odd) = [1, 2, 3, 4, 5].partition { $0 % 2 == 0 ?
			.left($0)
			: .right($0)
		}
		
		XCTAssertEqual(even, [2, 4])
		XCTAssertEqual(odd, [1, 3, 5])
	}
	
	func testPartitionEither() {
		let (even, odd) = [.right(1), .left(2), .right(3), .left(4), .right(5)].partition()
		
		XCTAssertEqual(even, [2, 4])
		XCTAssertEqual(odd, [1, 3, 5])
	}
}
