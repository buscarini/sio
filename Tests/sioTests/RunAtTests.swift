//
//  RunAtTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 13/04/2020.
//

import Foundation
import XCTest
import Sio

class RunAtTests: XCTestCase {
	func testRunAt() {
		let finish = expectation(description: "finish")
		
		let runDate = Date().addingTimeInterval(1)
		
		let sio = UIO<Int>
			.of(1)
			.runAt(runDate)
		
		sio.run { value in
			let interval = runDate.timeIntervalSinceNow
			XCTAssert(abs(interval) < 0.1)
			XCTAssertEqual(value, 1)
			finish.fulfill()
		}
		
		waitForExpectations(timeout: 1.1, handler: nil)
	}
}
