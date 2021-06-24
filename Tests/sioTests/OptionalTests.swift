//
//  OptionalTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 01/12/2019.
//

import XCTest
import Sio

class OptionalTests: XCTestCase {
	func testFromValue() {
		let expectation = self.expectation(description: "task succeeded")
		
		IO<String, Int>.from(3, default: 1)
			.fork({ _ in
				XCTFail()
			}) { value in
				XCTAssert(value == 3)
				expectation.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testFromNil() {
		let expectation = self.expectation(description: "task succeeded")
		
		IO<String, Int>.from(nil, default: 1)
			.fork({ _ in
				XCTFail()
			}) { value in
				XCTAssert(value == 1)
				expectation.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testOptional() {
		let expectation = self.expectation(description: "task succeeded")
		
		IO<String, Int>.of(1)
			.optional()
			.fork(absurd) { value in
				XCTAssert(value == 1)
				expectation.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testOptionalNil() {
		let expectation = self.expectation(description: "task succeeded")
		
		IO<String, Int>.rejected("a")
			.optional()
			.fork(absurd) { value in
				XCTAssert(value == nil)
				expectation.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testFromFNil() {
		let expectation = self.expectation(description: "task succeeded")
		
		SIO<Int, Void, Int>.from({ _ in
				nil
			})
			.provide(1)
			.fork({ value in
				XCTAssert(value == ())
				expectation.fulfill()
			}) { _ in
				XCTFail()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testFromFValue() {
		let expectation = self.expectation(description: "task succeeded")
		
		SIO<Int, Void, Int>.from({ $0 * 2 })
			.provide(2)
			.fork({ _ in
				XCTFail()
			}) { value in
				XCTAssert(value == 4)
				expectation.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testMap2() {
		let expectation = self.expectation(description: "task succeeded")
		
		let opt: Int? = 1
		
		let value = UIO<Int?>.of(opt).map2 { $0*2 }
		value.fork(absurd) { value in
			XCTAssert(value == 2)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testZipAnd() {
		let left = Optional<Int>.none
		let left2 = Optional<Int>.none
		let right = Optional<Int>.some(1)
		let right2 = Optional<Int>.some(2)

		XCTAssert((left <&> left2) == nil)
		
		XCTAssert((left <&> right) == nil)

		XCTAssert((right <&> left) == nil)

		XCTAssert((right <&> right2)?.0 == 1)
		XCTAssert((right <&> right2)?.1 == 2)
	}
	
	func testZip() {
		let left = Optional<Int>.none
		let left2 = Optional<Int>.none
		let right = Optional<Int>.some(1)
		let right2 = Optional<Int>.some(2)

		XCTAssert(zip2(left, left2) == nil)
		
		XCTAssert(zip2(left, right) == nil)

		XCTAssert(zip2(right, left) == nil)

		XCTAssert(zip2(right, right2)?.0 == 1)
		XCTAssert(zip2(right, right2)?.1 == 2)
	}
	
	func testZipWith() {
		let left = Optional<Int>.none
		let left2 = Optional<Int>.none
		let right = Optional<Int>.some(1)
		let right2 = Optional<Int>.some(2)
		
		XCTAssert(zip2(with: { ($0, $1) })(left, left2) == nil)
		
		XCTAssert(zip2(with: { ($0, $1) })(left, right) == nil)

		XCTAssert(zip2(with: { ($0, $1) })(right, left) == nil)

		XCTAssert(zip2(with: { ($0, $1) })(right, right2)?.0 == 1)
		XCTAssert(zip2(with: { ($0, $1) })(right, right2)?.1 == 2)
	}
	
	func testZip3() {
		let left = Optional<Int>.none
		let left2 = Optional<Int>.none
		let right = Optional<Int>.some(1)
		let right2 = Optional<Int>.some(2)

		XCTAssert(zip3(left, left, left2) == nil)
		
		XCTAssert(zip3(left, left2, right) == nil)

		XCTAssert(zip3(left, right, left2) == nil)
		
		XCTAssert(zip3(right, left, left2) == nil)

		XCTAssert(zip3(right, right, right2)?.0 == 1)
		XCTAssert(zip3(right, right, right2)?.1 == 1)
		XCTAssert(zip3(right, right, right2)?.2 == 2)
	}
	
	func testZip3With() {
		let left = Optional<Int>.none
		let left2 = Optional<Int>.none
		let right = Optional<Int>.some(1)
		let right2 = Optional<Int>.some(2)

		let z: (Optional<Int>, Optional<Int>, Optional<Int>) -> Optional<(Int, Int, Int)> = zip3(with: { (a: Int, b: Int, c: Int) -> (Int, Int, Int) in
			(a, b, c)
		})
		
		XCTAssert(z(left, left, left2) == nil)
		
		XCTAssert(z(left, left2, right) == nil)

		XCTAssert(z(left, right, left2) == nil)
		
		XCTAssert(z(right, left, left2) == nil)

		XCTAssert(z(right, right, right2)?.0 == 1)
		XCTAssert(z(right, right, right2)?.1 == 1)
		XCTAssert(z(right, right, right2)?.2 == 2)
	}
	
	func testZip4() {
		let left = Optional<Int>.none
		let left2 = Optional<Int>.none
		let right = Optional<Int>.some(1)
		let right2 = Optional<Int>.some(2)

		XCTAssert(zip4(left, left, left2, left2) == nil)
		
		XCTAssert(zip4(left, left2, left2, right) == nil)

		XCTAssert(zip4(left, right, left2, left2) == nil)
		
		XCTAssert(zip4(right, left, left2, left2) == nil)

		XCTAssert(zip4(right, right, right2, right2)?.0 == 1)
		XCTAssert(zip4(right, right, right2, right2)?.1 == 1)
		XCTAssert(zip4(right, right, right2, right2)?.2 == 2)
		XCTAssert(zip4(right, right, right2, right2)?.3 == 2)
	}
	
	func testZip4With() {
		let left = Optional<Int>.none
		let left2 = Optional<Int>.none
		let right = Optional<Int>.some(1)
		let right2 = Optional<Int>.some(2)

		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(left, left, left2, left2) == nil)
		
		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(left, left2, left2, right) == nil)

		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(left, right, left2, left2) == nil)
		
		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(right, left, left2, left2) == nil)

		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(right, right, right2, right2)?.0 == 1)
		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(right, right, right2, right2)?.1 == 1)
		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(right, right, right2, right2)?.2 == 2)
		XCTAssert(zip4(with: { ($0, $1, $2, $3) })(right, right, right2, right2)?.3 == 2)
	}
	
	func testTraverseNoNil() {
		let values: [Int] = [1, 2, 3, 4, 5 ]
		
		XCTAssertEqual(values.traverse { $0 > 0 ? $0 : nil }, values)
	}
	
	func testTraverseNil() {
		let values: [Int] = [1, 2, 3, 4, 5 ]
		
		XCTAssertNil(values.traverse { $0 > 2 ? $0 : nil })
	}
}
