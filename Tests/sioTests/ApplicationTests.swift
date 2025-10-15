import Foundation
import XCTest
import Sio

class ApplicationTests: XCTestCase {
	func inc(_ value: inout Int) {
		value += 1
	}
	
	func testRightApply() {
		let result = 1 |> { $0 + 1 }
		XCTAssertEqual(result, 2)
	}
	
	@MainActor
	func testRightApplyRef() async {
		let ref = Ref<Int>.init(1)

		let _ = await ref.update { value in
			value |> inc
		}
		
		let value = await ref.value()
		XCTAssertEqual(value, 2)
	}
	
	
	func testLeftApply() {
		let result = { $0 + 1 } <| 1
		XCTAssertEqual(result, 2)
	}
	
	func testLeftApplyRef() async {
		let ref = Ref<Int>.init(1)

		let _ = await ref.update { value in
			inc <| value
		}
		
		let result = await ref.value()
		XCTAssertEqual(result, 2)
	}
	
	func testApplyMutation() {
		var value = 1
		
		value |> { $0 += 1 }
		
		XCTAssertEqual(value, 2)
	}
	
	func testLeftApplyMutation() {
		var value: Int = 1
		
		({ $0 += 1 } <| value)
		
		XCTAssertEqual(value, 2)
	}
}
