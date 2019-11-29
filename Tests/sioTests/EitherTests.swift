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

	
	func testAlt() {
		let left = Either<Int, Int>.left(-1)
		let left2 = Either<Int, Int>.left(-2)
		let right = Either<Int, Int>.right(1)
		let right2 = Either<Int, Int>.right(2)
		
		let finalLeft = left <|> left2
		
		XCTAssert(finalLeft.isLeft)
		XCTAssert(finalLeft.left == -2)
		
		let finalRight = left <|> right
		
		XCTAssert(finalRight.isRight)
		XCTAssert(finalRight.right == 1)
		
		
		let finalRightR = right <|> right2
		
		XCTAssert(finalRightR.isRight)
		XCTAssert(finalRightR.right == 1)
	}
	
	func testAltDefault() {
		let left = Either<Int, Int>.left(-1)
		let right = Either<Int, Int>.right(1)

		let def = left <|> 2
		XCTAssert(def == 2)
		
		let r = right <|> 2
		XCTAssert(r == 1)
	}
}
