//
//  ChunksTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 30/11/2019.
//

import Foundation
import XCTest
import Sio

class ChunksTests: XCTestCase {
	
	func testEmpty() {
		let final = [].chunked(by: 5)
		XCTAssert(final.isEmpty)
	}
	
	func testSmall() {
		let initial = [ 1, 2]
		let final = initial.chunked(by: 5)
		XCTAssert(final.count == 1)
		XCTAssert(final.first == initial)
	}
	
	func testExact() {
		let initial = [ 1, 2, 3, 4]
		let final = initial.chunked(by: 2)
		XCTAssert(final.count == 2)
		XCTAssert(final.first == [ 1, 2])
		XCTAssert(final.last == [ 3, 4 ])
	}
	
	func testRemainder() {
		let initial = [ 1, 2, 3, 4, 5 ]
		let final = initial.chunked(by: 2)
		XCTAssert(final.count == 3)
		XCTAssert(final.first == [ 1, 2])
		XCTAssert(final[1] == [ 3, 4 ])
		XCTAssert(final.last == [ 5 ])
	}
}
