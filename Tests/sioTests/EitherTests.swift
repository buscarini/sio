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
	
	func testEq() {
		let left = Either<Int, String>.left(1)
		let left2 = Either<Int, String>.left(2)
		let right = Either<Int, String>.right("a")
		let right2 = Either<Int, String>.right("b")

		
		XCTAssert(left == left)
		XCTAssert(left != left2)
		XCTAssert(left != right)
		XCTAssert(right == right)
		XCTAssert(right != right2)
	}
	
	func testHash() {
		let left = Either<Int, String>.left(1)
		let left2 = Either<Int, String>.left(2)
		let right = Either<Int, String>.right("a")
		let right2 = Either<Int, String>.right("b")

		
		XCTAssert(left.hashValue != left2.hashValue)
		XCTAssert(left.hashValue != right.hashValue)
		XCTAssert(right.hashValue != right2.hashValue)
	}
	
	func testLeftDefault() {
		let left = Either<Int, String>.left(1)
		let right = Either<Int, String>.right("a")
		
		let leftVal = right.left(default: -1)
		let rightVal = left.right(default: "b")
		
		XCTAssert(leftVal == -1)
		XCTAssert(rightVal == "b")
		
		XCTAssert(left.left(default: 7) == 1)
		XCTAssert(right.right(default: "b") == "a")
	}
	
	func testFold() {
		let left = Either<Int, String>.left(1)
		let right = Either<Int, String>.right("a")

		let foldedLeft = left.fold({ "\($0)" }, { $0.uppercased() })
		let foldedRight = right.fold({ "\($0)" }, { $0.uppercased() })
		
		XCTAssert(foldedLeft == "1")
		XCTAssert(foldedRight == "A")
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
	
	func testSequence() {
		let leftA: [Either<Int, String>] = [ .right("a"), .left(1), .right("b") ]
		let rightA: [Either<Int, String>] = [ .right("a"), .right("b") ]
		
		let left = leftA.sequence()
		let right = rightA.sequence()
		
		XCTAssert(left.isLeft)
		XCTAssert(left.left == 1)
		
		XCTAssert(right.isRight)
		XCTAssert(right.right == [ "a", "b" ])		
	}
	
	func testZipAnd() {
		let left = Either<Int, Int>.left(-1)
		let left2 = Either<Int, Int>.left(-2)
		let right = Either<Int, Int>.right(1)
		let right2 = Either<Int, Int>.right(2)

		XCTAssert((left <&> left2).isLeft)
		XCTAssert((left <&> left2).left == -1)
		
		XCTAssert((left <&> right).isLeft)
		XCTAssert((left <&> right).left == -1)

		XCTAssert((right <&> left).isLeft)
		XCTAssert((right <&> left).left == -1)

		XCTAssert((right <&> right2).isRight)
		XCTAssert((right <&> right2).right?.0 == 1)
		XCTAssert((right <&> right2).right?.1 == 2)
	}
	
	func testZip() {
		let left = Either<Int, Int>.left(-1)
		let left2 = Either<Int, Int>.left(-2)
		let right = Either<Int, Int>.right(1)
		let right2 = Either<Int, Int>.right(2)

		XCTAssert(zip(left, left2).isLeft)
		XCTAssert(zip(left, left2).left == -1)
		
		XCTAssert(zip(left, right).isLeft)
		XCTAssert(zip(left, right).left == -1)

		XCTAssert(zip(right, left).isLeft)
		XCTAssert(zip(right, left).left == -1)

		XCTAssert(zip(right, right2).isRight)
		XCTAssert(zip(right, right2).right?.0 == 1)
		XCTAssert(zip(right, right2).right?.1 == 2)
	}
	
	func testZipWith() {
		let left = Either<Int, Int>.left(-1)
		let left2 = Either<Int, Int>.left(-2)
		let right = Either<Int, Int>.right(1)
		let right2 = Either<Int, Int>.right(2)
		
		XCTAssert(zip(with: { ($0, $1) })(left, left2).isLeft)
		XCTAssert(zip(with: { ($0, $1) })(left, left2).left == -1)
		
		XCTAssert(zip(with: { ($0, $1) })(left, right).isLeft)
		XCTAssert(zip(with: { ($0, $1) })(left, right).left == -1)

		XCTAssert(zip(with: { ($0, $1) })(right, left).isLeft)
		XCTAssert(zip(with: { ($0, $1) })(right, left).left == -1)

		XCTAssert(zip(with: { ($0, $1) })(right, right2).isRight)
		XCTAssert(zip(with: { ($0, $1) })(right, right2).right?.0 == 1)
		XCTAssert(zip(with: { ($0, $1) })(right, right2).right?.1 == 2)
	}
	
	func testZip3() {
		let left = Either<Int, Int>.left(-1)
		let left2 = Either<Int, Int>.left(-2)
		let right = Either<Int, Int>.right(1)
		let right2 = Either<Int, Int>.right(2)

		XCTAssert(zip3(left, left, left2).isLeft)
		XCTAssert(zip3(left, left, left2).left == -1)
		
		XCTAssert(zip3(left, left2, right).isLeft)
		XCTAssert(zip3(left, left2, right).left == -1)

		XCTAssert(zip3(left, right, left2).isLeft)
		XCTAssert(zip3(left, right, left2).left == -1)
		
		XCTAssert(zip3(right, left, left2).isLeft)
		XCTAssert(zip3(right, left, left2).left == -1)

		XCTAssert(zip3(right, right, right2).isRight)
		XCTAssert(zip3(right, right, right2).right?.0 == 1)
		XCTAssert(zip3(right, right, right2).right?.1 == 1)
		XCTAssert(zip3(right, right, right2).right?.2 == 2)
	}
	
	func testZip3With() {
		let left = Either<Int, Int>.left(-1)
		let left2 = Either<Int, Int>.left(-2)
		let right = Either<Int, Int>.right(1)
		let right2 = Either<Int, Int>.right(2)

		let z: (Either<Int, Int>, Either<Int, Int>, Either<Int, Int>) -> Either<Int, (Int, Int, Int)> = zip3(with: { (a: Int, b: Int, c: Int) -> (Int, Int, Int) in
			(a, b, c)
		})
		
		XCTAssert(z(left, left, left2).isLeft)
		XCTAssert(z(left, left, left2).left == -1)
		
		XCTAssert(z(left, left2, right).isLeft)
		XCTAssert(z(left, left2, right).left == -1)

		XCTAssert(z(left, right, left2).isLeft)
		XCTAssert(z(left, right, left2).left == -1)
		
		XCTAssert(z(right, left, left2).isLeft)
		XCTAssert(z(right, left, left2).left == -1)

		XCTAssert(z(right, right, right2).isRight)
		XCTAssert(z(right, right, right2).right?.0 == 1)
		XCTAssert(z(right, right, right2).right?.1 == 1)
		XCTAssert(z(right, right, right2).right?.2 == 2)
	}
	
	func testZip4() {
		let left = Either<Int, Int>.left(-1)
		let left2 = Either<Int, Int>.left(-2)
		let right = Either<Int, Int>.right(1)
		let right2 = Either<Int, Int>.right(2)

		XCTAssert(zip4(left, left, left2, left2).isLeft)
		XCTAssert(zip4(left, left, left2, left2).left == -1)
		
		XCTAssert(zip4(left, left2, left2, right).isLeft)
		XCTAssert(zip4(left, left2, left2, right).left == -1)

		XCTAssert(zip4(left, right, left2, left2).isLeft)
		XCTAssert(zip4(left, right, left2, left2).left == -1)
		
		XCTAssert(zip4(right, left, left2, left2).isLeft)
		XCTAssert(zip4(right, left, left2, left2).left == -1)

		XCTAssert(zip4(right, right, right2, right2).isRight)
		XCTAssert(zip4(right, right, right2, right2).right?.0 == 1)
		XCTAssert(zip4(right, right, right2, right2).right?.1 == 1)
		XCTAssert(zip4(right, right, right2, right2).right?.2 == 2)
		XCTAssert(zip4(right, right, right2, right2).right?.3 == 2)
	}
	
	func testZip4With() {
		let left = Either<Int, Int>.left(-1)
		let left2 = Either<Int, Int>.left(-2)
		let right = Either<Int, Int>.right(1)
		let right2 = Either<Int, Int>.right(2)

		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(left, left, left2, left2).isLeft)
		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(left, left, left2, left2).left == -1)
		
		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(left, left2, left2, right).isLeft)
		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(left, left2, left2, right).left == -1)

		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(left, right, left2, left2).isLeft)
		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(left, right, left2, left2).left == -1)
		
		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(right, left, left2, left2).isLeft)
		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(right, left, left2, left2).left == -1)

		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(right, right, right2,  right2).isRight)
		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(right, right, right2, right2).right?.0 == 1)
		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(right, right, right2, right2).right?.1 == 1)
		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(right, right, right2, right2).right?.2 == 2)
		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(right, right, right2, right2).right?.3 == 2)
	}
	
	func testSwapped() {
		let left = Either<Int, Int>.left(-1)
		let right = Either<Int, Int>.right(1)

		XCTAssert(left.swapped.isRight)
		XCTAssert(left.swapped.right == -1)
		XCTAssert(right.swapped.isLeft)
		XCTAssert(right.swapped.left == 1)
	}
	
	func testCodable() {
		let left = Either<String, Int>.left("a")
		let right = Either<String, Int>.right(1)
		
		let data = try! JSONEncoder().encode(left)
		let decodedLeft = try! JSONDecoder().decode(Either<String, Int>.self, from: data)
		XCTAssert(left == decodedLeft)
		
		let data2 = try! JSONEncoder().encode(right)
		let decodedRight = try! JSONDecoder().decode(Either<String, Int>.self, from: data2)
		XCTAssert(right == decodedRight)
	}
	
	func testTraverseLeft() {
		let left = Either<String, Int>.left("a")
		
		let nilResult: Either<String, Int>? = traverseLeft(left) { string in
			return nil
		}
		
		let valueResult: Either<String, Int>? = traverseLeft(left) { string in
			string + "b"
		}
		
		XCTAssert(nilResult == nil)
		XCTAssert(valueResult?.left == "ab")
	}
}
