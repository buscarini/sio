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
	
	func testZipWith() {
		let finish = expectation(description: "finish")
		
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)
		
		zip2(with: { ($0, $1) })(left, left2)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip2(with: { ($0, $1) })(left, right)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip2(with: { ($0, $1) })(right, left)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip2(with: { ($0, $1) })(right, right2)
		.fork({ _ in
			XCTFail()
		}) { both in
			XCTAssert(both.0 == 1)
			XCTAssert(both.1 == 2)
			
			finish.fulfill()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testZip3() {
		let finish = expectation(description: "finish")
		
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)
		
		zip3(left, left2, left2)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip3(left, left2, right)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip3(right, left, left2)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip3(right, right, right2)
		.fork({ _ in
			XCTFail()
		}) { both in
			XCTAssert(both.0 == 1)
			XCTAssert(both.1 == 1)
			XCTAssert(both.2 == 2)
			
			finish.fulfill()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testZip3With() {
		let finish = expectation(description: "finish")
		
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)
		
		zip3(with: { ($0, $1, $2) })(left, left, left2)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip3(with: { ($0, $1, $2) })(left, right, right2)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip3(with: { ($0, $1, $2) })(right, left, left2)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip3(with: { ($0, $1, $2) })(right, right, right2)
		.fork({ _ in
			XCTFail()
		}) { both in
			XCTAssert(both.0 == 1)
			XCTAssert(both.1 == 1)
			XCTAssert(both.2 == 2)
			
			finish.fulfill()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testZip4() {
		let finish = expectation(description: "finish")
		
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)
		
		zip4(left, left2, left2, left)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip4(left, left2, right, right2)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip4(right, left, left2, right)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip4(right, right, right2, right2)
		.fork({ _ in
			XCTFail()
		}) { both in
			XCTAssert(both.0 == 1)
			XCTAssert(both.1 == 1)
			XCTAssert(both.2 == 2)
			XCTAssert(both.3 == 2)
			
			finish.fulfill()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testZip4With() {
		let finish = expectation(description: "finish")
		
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)
		
		zip4(with: { ($0, $1, $2, $3) })(left, left, left, left2)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip4(with: { ($0, $1, $2, $3) })(left, right, right2, right)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip4(with: { ($0, $1, $2, $3) })(right, left, left2, right)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip4(with: { ($0, $1, $2, $3) })(right, right, right2, right2)
		.fork({ _ in
			XCTFail()
		}) { both in
			XCTAssert(both.0 == 1)
			XCTAssert(both.1 == 1)
			XCTAssert(both.2 == 2)
			XCTAssert(both.3 == 2)
			
			finish.fulfill()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
