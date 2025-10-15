import Foundation
import XCTest
import Sio
import SioValueStore

class SIOValueStoreTests: XCTestCase {
	func testOf() {
		let scheduler = DispatchQueue.test
		ValueStore<Void, String, Int, Int>.of(1)
			.load
			.assert(1, scheduler: scheduler)
	}
	
	func testOfSave() {
		let scheduler = DispatchQueue.test

		ValueStore<Void, String, Int, Int>.of(1)
			.save(2)
			.assert(1, scheduler: scheduler)
	}
	
	func testRejected() {
		let scheduler = DispatchQueue.test

		ValueStore<Void, String, Int, Int>.rejected("err")
			.load
		.assertErr("err", scheduler: scheduler)
	}
	
	func testRejectedSave() {
		let scheduler = DispatchQueue.test

		ValueStore<Void, String, Int, Int>.rejected("err")
			.save(1)
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
	
	@MainActor
	func testMove() async throws {
		let fromRef = Ref<Int?>.init(1)
		let toRef = Ref<Int?>.init(nil)
		
		let from = await fromRef.valueStore()
		let to = await toRef.valueStore()
		
		let value = try await from.move(to: to, adapt: id).constError(SIOError.empty).task
		
		XCTAssert(value == 1)
				
		let fromValue = await fromRef.value()
		XCTAssertEqual(fromValue, nil)
		
		let toValue = await toRef.value()
		XCTAssertEqual(toValue, 1)
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
			remove: SIO.sync({ _ in
				cachedVar = nil
				return .right(())
			})
		)
		
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
		let scheduler = DispatchQueue.test

		ValueStore<Void, String, Int, Int>.of(1)
			.optional()
			.load
			.assert(1, scheduler: scheduler)
	}
	
	func testOptionalSomeSave() {
		let scheduler = DispatchQueue.test

		ValueStore<Void, String, Int, Int>.of(1)
			.optional()
			.save(2)
			.assert(1, scheduler: scheduler)
	}
	
	func testOptionalNone() {
		let scheduler = DispatchQueue.test

		ValueStore<Void, String, Int, Int>.rejected("err")
			.optional()
			.load
			.assert(nil, scheduler: scheduler)
	}
	
	func testOptionalNoneSave() {
		let scheduler = DispatchQueue.test

		ValueStore<Void, String, Int, Int>.rejected("err")
			.optional()
			.save(1)
			.assert(nil, scheduler: scheduler)
	}
	
	func testDefault() {
		let scheduler = DispatchQueue.test

		ValueStore<Void, String, Int, Int>.rejected("err")
			.default(1)
			.load
			.assert(1, scheduler: scheduler)
	}
	
	@MainActor
	func testReplacingLoadOld() async throws {
		let fromRef = Ref<Int?>.init(1)
		let toRef = Ref<Int?>.init(nil)
		
		let from = await fromRef.valueStore()
		let to = await toRef.valueStore()
		
		let final = to.replacing(from)
		
		let value = try await final.load.constError(SIOError.empty).task
		
		XCTAssert(value == 1)
				
		let fromValue = await fromRef.value()
		XCTAssertEqual(fromValue, nil)
		
		let toValue = await toRef.value()
		XCTAssertEqual(toValue, 1)
	}
	
	@MainActor
	func testReplacingLoadNew() async throws {
		let fromRef = Ref<Int?>.init(2)
		let toRef = Ref<Int?>.init(1)
		
		let from = await fromRef.valueStore()
		let to = await toRef.valueStore()
		
		let final = to.replacing(from)
		
		let value = try await final.load.constError(SIOError.empty).task
		XCTAssert(value == 1)
			
		let fromValue = await fromRef.value()
		XCTAssertEqual(fromValue, nil)
		
		let toValue = await toRef.value()
		XCTAssertEqual(toValue, 1)
	}
	
	@MainActor
	func testReplacingSave() async throws {
		let fromRef = Ref<Int?>.init(nil)
		let toRef = Ref<Int?>.init(nil)

		let from = await fromRef.valueStore()
		let to = await toRef.valueStore()

		let replacing = to.replacing(from)

		let value = try await replacing.save(2).constError(SIOError.empty).task
		
		XCTAssert(value == 2)
				
		let fromValue = await fromRef.value()
		XCTAssertEqual(fromValue, nil)
		
		let toValue = await toRef.value()
		XCTAssertEqual(toValue, 2)
	}
	
	@MainActor
	func testReplacingRemove() async throws {
		let fromRef = Ref<Int?>.init(2)
		let toRef = Ref<Int?>.init(1)

		let from = await fromRef.valueStore()
		let to = await toRef.valueStore()

		let replacing = to.replacing(from)

		try await replacing.remove.constError(SIOError.empty).task
		
		let fromValue = await fromRef.value()
		XCTAssertEqual(fromValue, nil)
		
		let toValue = await toRef.value()
		XCTAssertEqual(toValue, nil)
	}
	
	func testCancelLoad() {
		let store = ValueStore<Void, String, Int, Int>.of(1)
		store.load.cancel()

		let expectLoad = expectation(description: "load")
		
		store.load.fork({ _ in
			XCTFail()
		}) { value in
			XCTAssertEqual(value, 1)
			expectLoad.fulfill()
		}
		
		waitForExpectations(timeout: 1)
	}
}
