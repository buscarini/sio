//
//  EitherTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 29/11/2019.
//

import Foundation
import XCTest
import Sio

class EitherTests: XCTestCase {
	enum TestError: Error {
		case unknown
	}
	
	func testOptionalDefault() {
		let noValue: Int? = nil
		let value: Int? = 1
		
		
		let def = Either<Void, Int>.from(noValue, default: 4)
		let right = Either<Void, Int>.from(value, default: 4)
		
		XCTAssert(def.isRight)
		XCTAssert(def.right == 4)
		XCTAssert(right.isRight)
		XCTAssert(right.right == 1)
	
		XCTAssert(def.optional() == 4)
		XCTAssert(right.optional() == 1)
	}
	
	func testOptionalError() {
		let noValue: Int? = nil
		let value: Int? = 1
		
		let left = Either.from(noValue, TestError.unknown)
		let right = Either.from(value, TestError.unknown)
		
		XCTAssert(left.isLeft)
		XCTAssert(left.left == .unknown)
		XCTAssert(right.isRight)
		XCTAssert(right.right == 1)
	
		XCTAssert(left.optional() == nil)
		XCTAssert(right.optional() == 1)
	}
	
}
