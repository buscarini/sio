//
//  OptionalTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 01/12/2019.
//

import XCTest
import Sio

class OptionalTests: XCTestCase {
	
	func testMap2() {
		let expectation = self.expectation(description: "task succeeded")
		
		let opt: Int? = 1
		
		let value = UIO<Int?>.of(opt).map2 { $0*2 }
		value.fork(absurd) { value in
			XCTAssert(value == 2)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
