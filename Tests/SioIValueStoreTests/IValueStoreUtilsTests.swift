//
//  ValueStoreUtilsTests.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 15/04/2020.
//

import Foundation
import XCTest
import Sio
import SioIValueStore

class SIOIValueStoreUtilsTests: XCTestCase {
	func testMigration() {
		let finish = expectation(description: "finish")

		let sourceRef = Ref<[String: Int]>.init(["key": 6])
		let targetRef = Ref<[String: Int]>.init([:])
		
		let origin = sourceRef.iValueStore()
		let target = targetRef.iValueStore()
		
		target.migrate(from: origin, key: "key")
			.fork((), { _ in
				XCTFail()
			}, { value in
				XCTAssertEqual(sourceRef.state, [:])
				XCTAssertEqual(value, 6)
				XCTAssertEqual(targetRef.state, ["key": 6])
				
				finish.fulfill()
			})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
