//
//  NoSyncValueTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 05/12/2019.
//

import Foundation

import XCTest
@testable import Sio

class NoSyncValueTests: XCTestCase {
	func testNotLoaded() {
		let value = NoSyncValue<Void, Int>()
		value.result = .notLoaded
		
		XCTAssert(value.notLoaded)
		
		value.result = .loaded(.right(1))
		
		XCTAssert(value.notLoaded == false)
	}
}
