//
//  ContravariantTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 13/04/2020.
//

import Foundation
import XCTest
import Sio

class ContravariantTests: XCTestCase {
	func testPullbackAll() {
		let finish = expectation(description: "finish")
		
		let sio = SIO<Int, Never, Int>.sync { value in
			.right(value*2)
		}
		
		let range = sio.pullbackAll { int in
			Array(0...int)
		}
		
		range.provide(3).runMain((), { values in
			XCTAssertEqual(values, [0, 2, 4, 6])
			finish.fulfill()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
