//
//  SioRandomTests.swift
//  SioEffectsTests
//
//  Created by José Manuel Sánchez Peñarroja on 13/08/2019.
//

import Foundation
import XCTest

import Sio
import SioEffects

class SIORandomTests: XCTestCase {
	func testLCRNG() {
		var gen = LCRNG(seed: 1)
		
		XCTAssert(gen.next() == 2862933558814942250)
		XCTAssert(gen.next() == 11788423209769308335)
		XCTAssert(gen.next() == 16127330271062048800)
		XCTAssert(gen.next() == 694254729704690381)
	}
	
	func testRandom() {
		let finish = expectation(description: "finished")
		
		let gen = LCRNG(seed: 1)

		Random.Default.randomInt(0...9).fork(.init(.init(gen)), absurd, { num in
			XCTAssert(num == 0)
			finish.fulfill()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
