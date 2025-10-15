import Foundation
import XCTest

import CombineSchedulers

import Sio
import SioIValueStore

class SIOCodecTests: XCTestCase {
	func testOf() {
		let scheduler = DispatchQueue.test
		
		IValueStore<Void, Int, String, Int, Int>.of(1)
			.load(1)
			.assert(1, scheduler: scheduler)
	}
	
	func testRejected() {
		let scheduler = DispatchQueue.test

		IValueStore<Void, Int, String, Int, Int>.rejected("err")
			.load(1)
			.assertErr("err", scheduler: scheduler)
	}
	
	func testCopy() {
		let finish = expectation(description: "finish")

		var targetVar: Int = 0
		
		let origin = IValueStoreA<Void, Int, String, Int>.of(6)
		
		let target = IValueStoreA<Void, Int, String, Int>.init(
			load: { k in
				SIO.sync({ _ in
					return .right(targetVar)
				})
			},
			save: { k, a in
				return SIO.init { _ in
					targetVar = a
					return .right(a)
				}
			},
			remove: { _ in SIO.of(()) }
		)
		
		origin.copy(to: target, key: 1, adapt: Sio.id)
			.fork((), { _ in
				XCTFail()
			}, { value in
				XCTAssert(value == 6)
				
				target.load(1).fork({ _ in
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
		
		let origin = IValueStoreA<Void, Int, String, Int>.rejected("err")
		
		let target = IValueStoreA<Void, Int, String, Int>.init(
			load: { _ in
				SIO.sync({ _ in
					.right(targetVar)
				})
			},
			save: { _, a in
				SIO.init { _ in
					targetVar = a
					return .right(a)
				}
			},
			remove: { _ in SIO.of(()) }
		)
		
		origin.copy(to: target, key: 1, adapt: Sio.id)
			.fork((), { err in
				XCTAssert(err == "err")
				target.load(1).fork({ _ in
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
}
