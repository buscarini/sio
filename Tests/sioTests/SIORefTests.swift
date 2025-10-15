import Foundation
import XCTest
import Sio

class SioRefTests: XCTestCase {
	@MainActor
	func testRefGetFree() async throws {
		let ref = Ref<Int>.init(1)
		
		let arg = try await get(SIO<Ref<Int>, Error, Void>.environment()).provide(ref).task
		
		let (value, _) = arg
		XCTAssert(value == 1)
		
		let refValue = await ref.value()
		XCTAssert(refValue == 1)
	}
	
	@MainActor
	func testRefModifyFree() async throws {
		let ref = Ref<Int>.init(1)
		
		let arg = try await modify(SIO<Ref<Int>, Never, Void>.environment())({ (value: Int) in
				value * 2
			}).get().provide(ref).task
		
		let (value, _) = arg
		XCTAssert(value == 2)
		
		let refValue = await ref.value()
		XCTAssert(refValue == 2)
	}
	
	@MainActor
	func testRefModify() async throws {
		let ref = Ref<Int>.init(1)
		
		let arg = try await SIO<Ref<Int>, Never, Void>.environment()
			.modify { value in
				value * 2
			}
			.get()
			.provide(ref).task
		
		let (value, _) = arg
		XCTAssert(value == 2)
		
		let refValue = await ref.value()
		XCTAssert(refValue == 2)
	}
	
	@MainActor
	func testRefSetFree() async throws {
		let ref = Ref<Int>.init(1)
		
		let arg = try await set(SIO<Ref<Int>, Never, Void>.environment())(2)
			.get()
			.provide(ref).task

		let (value, _) = arg
		XCTAssert(value == 2)
		let refValue = await ref.value()
		XCTAssert(refValue == 2)
	}
	
	@MainActor
	func testRefSet() async throws {
		let ref = Ref<Int>.init(1)
		
		let arg = try await SIO<Ref<Int>, Never, Void>.environment()
			.set(2)
			.get()
			.provide(ref).task
		
		let (value, _) = arg
		XCTAssert(value == 2)
		
		let refValue = await ref.value()
		XCTAssert(refValue == 2)
	}
}
