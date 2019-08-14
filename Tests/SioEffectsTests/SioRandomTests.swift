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
	
	func testRandomInt() {
		let finish = expectation(description: "finished")
		
		let gen = LCRNG(seed: 1)

		Random.Default.randomInt(0...9)
			.fork(.init(.init(gen)), absurd, { num in
				XCTAssert(num == 0)
				finish.fulfill()
			})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testRandomId() {
		let finish = expectation(description: "finished")

		let rnd = Random()
		let gen = LCRNG(seed: 1)

		let segment = rnd.oneOf([
			rnd.digit(),
			rnd.uppercaseLetter()
		])
			.replicateM(6)
			.map { $0.joined() }
		
		let id = segment
			.replicateM(3)
			.map { $0.joined(separator: "-") }
			
		id
			.fork(.init(.init(gen)), {
				XCTFail()
			}, { id in
				XCTAssert(id == "515995-777315-555151")
				finish.fulfill()
			})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
