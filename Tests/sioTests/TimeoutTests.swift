//
//  TimeoutTests.swift
//  sio-iOS Tests
//
//  Created by José Manuel Sánchez Peñarroja on 23/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import XCTest
import sio

class TimeoutTests: XCTestCase {
	func testTimeoutTo() {
		let finish = expectation(description: "finish")

		let task = UIO.of(1).delay(10).timeoutTo(0, 0.1)
		
		task.run((), { value in
			XCTAssert(value == 0)
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 1)
	}
	
	func testTimeout() {
		let finish = expectation(description: "finish")
		
		let task = UIO.of(1).delay(10).timeout(0.1)
		
		task.run((), { value in
			XCTAssert(value == nil)
			finish.fulfill()
		})
		
		wait(for: [finish], timeout: 1)
	}
}
