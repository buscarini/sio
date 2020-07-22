//
//  ProfunctorTests.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 30/05/2020.
//

import Foundation
import Sio
import XCTest

class ProfunctorTests: XCTestCase {
	func testDiMap() {
		let finish = expectation(description: "finish")
		
		let mapped: SIO<String, Void, Int> = environment(Int.self)
			.dimap(
				{ $0.count },
				{ $0 * 2 }
			)
		
		mapped.fork("hello", { _ in
			XCTFail()
		}) { value in
			XCTAssertEqual(value, 10)
			finish.fulfill()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	
	func testDiMapCancel() {
		let finish = expectation(description: "finish")
		finish.isInverted = true
		
		let mapped: SIO<String, Void, Int> = environment(Int.self)
			.dimap(
				{ $0.count },
				{ $0 * 2 }
			)
		
		mapped.cancel()
		
		mapped.fork("hello", { _ in
			finish.fulfill()
		}) { value in
			finish.fulfill()
		}
		
		waitForExpectations(timeout: 0.1, handler: nil)
	}
	
}
