//
//  RequirementTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 13/04/2020.
//

import Foundation
import XCTest
import Sio

class RequirementTests: XCTestCase {
	func testAccess() {
		let finish = expectation(description: "finish")
		
		SIO<Int, Never, Int>
			.of(1)
			.access()
			.provide(4)
			.run { value in
				XCTAssertEqual(value, 4)
				finish.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testToFunc() {
		let finish = expectation(description: "finish")
		
		SIO<Int, Never, Int>.sync { value in
			.right(value * 2)
		}
		.toFunc()(2)
		.run { value in
			XCTAssertEqual(value, 4)
			finish.fulfill()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testFromFunc() {
		let finish = expectation(description: "finish")
		
		func f(_ input: Int) -> SIO<Void, Never, Int> {
			.of(2 * input)
		}
		
		SIO.fromFunc(f)
		.provide(2)
		.run { value in
			XCTAssertEqual(value, 4)
			finish.fulfill()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
