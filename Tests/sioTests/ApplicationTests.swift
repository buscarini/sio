//
//  ApplicationTests.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 24/12/2019.
//

import Foundation
import XCTest
import Sio

class ApplicationTests: XCTestCase {
	
	func incRef(_ ref: Ref<Int>) {
		ref.state += 1
	}
	
	func testRightApply() {
		let result = 1 |> { $0 + 1 }
		XCTAssertEqual(result, 2)
	}
	
	func testRightApplyRef() {
		let ref = Ref<Int>.init(1)

		let result = ref |> incRef
		XCTAssertEqual(result.state, 2)
	}
	
	
	func testLeftApply() {
		let result = { $0 + 1 } <| 1
		XCTAssertEqual(result, 2)
	}
	
	func testLeftApplyRef() {
		let ref = Ref<Int>.init(1)

		let result = incRef <| ref
		XCTAssertEqual(result.state, 2)
	}
	
	func testApplyMutation() {
		var value = 1
		
		value |> { $0 += 1 }
		
		XCTAssertEqual(value, 2)
	}
	
//	func testLeftApplyMutation() {
//		var value: Int = 1
//		
//		let result = { $0 += 1 } <| value
//		
//		XCTAssertEqual(result, 2)
//	}
}
