//
//  ValueStoreUtilsTests.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 15/04/2020.
//

import Foundation
import XCTest
import Sio
import SioValueStore

class SIOValueStoreUtilsTests: XCTestCase {
	func testMigration() {
		let finish = expectation(description: "finish")

		let sourceRef = Ref<Int?>.init(6)
		let targetRef = Ref<Int?>.init(nil)
		
		let origin = sourceRef.valueStore()
		let target = targetRef.valueStore()
		
		target.migrate(from: origin)
			.fork((), { _ in
				XCTFail()
			}, { value in
				XCTAssertNil(sourceRef.state)
				XCTAssertEqual(value, 6)
				XCTAssertEqual(targetRef.state, 6)
				
				finish.fulfill()
			})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
