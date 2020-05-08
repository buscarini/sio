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

		var targetVar: Int = 0
		
		let origin = ValueStoreA<Void, String, Int>.of(6)
		
		let target = ValueStoreA<Void, String, Int>.init(
			load: SIO.sync({ _ in
				return .right(targetVar)
			}),
			save: { a in
				SIO.init { _ in
					targetVar = a
					return .right(a)
				}
			},
			remove: SIO.of(())
		)
		
		target.migrate(from: origin)
			.fork((), { _ in
				XCTFail()
			}, { value in
				XCTAssert(value == 6)
				
				target.load.fork({ _ in
					XCTFail()
				}, { value in
					XCTAssert(value == 6)
					finish.fulfill()
				})
			})
		
		waitForExpectations(timeout: 1, handler: nil)
		
		
	}
	
}
