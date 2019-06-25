//
//  SIOValueStoreTests.swift
//  SIOValueStore
//
//  Created by José Manuel Sánchez on 19/5/19.
//  Copyright © 2019 SIOValueStoreTests. All rights reserved.
//

import Foundation
import XCTest
import Sio
import SioValueStore

class SIOValueStoreTests: XCTestCase {
	func testOf() {
		let finish = expectation(description: "finish")
		
		ValueStore<Void, String, Int, Int>.of(1).load.fork({ _ in
			XCTFail()
		}, { value in
			XCTAssert(value == 1)
			finish.fulfill()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testRejected() {
		let finish = expectation(description: "finish")
		
		ValueStore<Void, String, Int, Int>.rejected("err").load.fork({ err in
			XCTAssert(err == "err")
			finish.fulfill()
		}, { _ in
			XCTFail()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
