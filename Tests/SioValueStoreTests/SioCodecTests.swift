import Foundation
import XCTest

import CombineSchedulers

import Sio
import SioValueStore

class SIOCodecTests: XCTestCase {
	func testOf() {
		let scheduler = DispatchQueue.test
		
		ValueStore<Void, String, Int, Int>.of(1)
			.load
			.assert(1, scheduler: scheduler)
	}
	
	func testRejected() {
		let scheduler = DispatchQueue.test

		ValueStore<Void, String, Int, Int>.rejected("err")
			.load
			.assertErr("err", scheduler: scheduler)
	}
	
	func testCopy() {
		let finish = expectation(description: "finish")

		var targetVar: Int = 0
		
		let origin = ValueStoreA<Void, String, Int>.of(6)
		
		let target = ValueStoreA<Void, String, Int>.init(
			load: SIO.sync({ _ in
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
			load: SIO.sync({ _ in
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
}
