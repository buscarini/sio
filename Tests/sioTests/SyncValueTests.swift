//
//  SyncValueTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 06/12/2019.
//

import Foundation
import XCTest
@testable import Sio

class SyncValueTests: XCTestCase {
	func testNotLoaded() {
		let value = SyncValue<Void, Int>()
		value.result = .notLoaded
		
		XCTAssert(value.notLoaded)
		XCTAssert(value.loaded == false)
		
		value.result = .loaded(.right(1))
		
		XCTAssert(value.notLoaded == false)
		XCTAssert(value.loaded == true)
	}
}
