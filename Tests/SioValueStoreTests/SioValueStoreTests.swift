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
		ValueStore<Void, String, Int, Int>.of(1)
			.load
		.assert(1)
	}
	
	func testRejected() {
		ValueStore<Void, String, Int, Int>.rejected("err")
			.load
		.assertErr("err")
	}
	
	func testCopy() {
		let finish = expectation(description: "finish")

		var targetVar: Int = 0
		
		let origin = ValueStoreA<Void, String, Int>.of(6)
		
		let target = ValueStoreA<Void, String, Int>.init(
			load: SIO.init({ _ in
				return .right(targetVar)
			}),
			save: { a in
				return SIO.init { _ in
					targetVar = a
					return .right(a)
				}
			},
			remove: SIO.of(())
		)
		
		origin.copy(to: target, adapt: Sio.id)
			.pullback { _ in ((), ()) }
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
	
	func testCopyFail() {
		let finish = expectation(description: "fail")
		
		var targetVar: Int = 0
		
		let origin = ValueStoreA<Void, String, Int>.rejected("err")
		
		let target = ValueStoreA<Void, String, Int>.init(
			load: SIO.init({ _ in
				return .right(targetVar)
			}),
			save: { a in
				return SIO.init { _ in
					targetVar = a
					return .right(a)
				}
		},
			remove: SIO.of(())
		)
		
		origin.copy(to: target, adapt: Sio.id)
			.pullback { _ in ((), ()) }
			.fork((), { err in
				XCTAssert(err == "err")
				target.load.fork({ _ in
					XCTFail()
				}, { value in
					XCTAssert(value == 0)
					finish.fulfill()
				})
			}, { value in
				XCTFail()
			})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testCache() {
		let finish = expectation(description: "finish")

		var cachedVar: Int?
		var targetVar: Int = 0
		
		let cache = ValueStoreA<Void, String, Int>.init(
			load: SIO.from(cachedVar, "error"),
			save: { a in
				return SIO.init { _ in
					cachedVar = a
					return .right(a)
				}
			},
			remove: SIO.init({ _ in
				cachedVar = nil
				return .right(())
			})
		)
		
		let target = ValueStoreA<Void, String, Int>.init(
			load: SIO.init({ _ in
				return .right(targetVar)
			}),
			save: { a in
				return SIO.init { _ in
					targetVar = a
					return .right(a)
				}
			},
			remove: SIO.of(())
		)
		
		let cached = target.cached(by: cache)
		
		cached.save(8)
			.fork((), { _ in
				XCTFail()
			}, { value in
				XCTAssert(value == 8)
				XCTAssert(cachedVar == 8)
				XCTAssert(targetVar == 8)
				
				cached.load.fork({ _ in
					XCTFail()
				}, { value in
					XCTAssert(value == 8)	
					
					finish.fulfill()
				})
			})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testOptionalSome() {
		ValueStore<Void, String, Int, Int>.of(1)
			.optional()
			.load
			.assert(1)
	}
	
	func testOptionalNone() {
		ValueStore<Void, String, Int, Int>.rejected("err")
			.optional()
			.load
			.assert(nil)
	}
	
	func testOptionalRemove() {
		ValueStore<Void, String, Int, Int>.rejected("err")
			.optional()
			.load
			.assert(nil)
	}
}
