//
//  SIOZipTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 03/12/2019.
//

import Foundation
import XCTest
import Sio

class SioZipTests: XCTestCase {
	func testZipAnd() {
		let finish = expectation(description: "finish")
		
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)
		
		(left <&> left2)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		(left <&> right)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		(right <&> left)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		(right <&> right2)
		.fork({ _ in
			XCTFail()
		}) { both in
			XCTAssert(both.0 == 1)
			XCTAssert(both.1 == 2)
			
			finish.fulfill()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testZip() {
		let finish = expectation(description: "finish")
		
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)
		
		zip(left, left2)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip(left, right)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip(right, left)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip(right, right2)
		.fork({ _ in
			XCTFail()
		}) { both in
			XCTAssert(both.0 == 1)
			XCTAssert(both.1 == 2)
			
			finish.fulfill()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	/*func testZip() {
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)

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
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)
		
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
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)

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
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)

		let z: (IO<Int, Int>, IO<Int, Int>, IO<Int, Int>) -> IO<Int, (Int, Int, Int)> = zip3(with: { (a: Int, b: Int, c: Int) -> (Int, Int, Int) in
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
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)

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
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)

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
	}*/
}
