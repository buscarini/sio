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
			XCTAssert(e == -2)
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
	
	func testSimpleZip() {
		let scheduler = TestScheduler()

		let finish = expectation(description: "finish")
		
		let left = IO<Int, Int>.of(1)
		let right = IO<Int, Int>.of(2)
		
		zip(left, right, scheduler)
		.fork({ _ in
			XCTFail()
		}) { (l, r) in
			XCTAssertEqual(l, 1)
			XCTAssertEqual(r, 2)
			finish.fulfill()
		}
		
		scheduler.advance()
		
		waitForExpectations(timeout: 100, handler: nil)
	}
	
	func testZip() {
		let scheduler = TestScheduler()

		let finish = expectation(description: "finish")
		
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)
		
		zip(left, left2, scheduler)
		.fork({ e in
			XCTAssert(e == -2)
		}) { (_) in
			XCTFail()
		}
		
		scheduler.advance()
		
		zip(left, right, scheduler)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		scheduler.advance()
		
		zip(right, left, scheduler)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		scheduler.advance()
		
		zip(right, right2, scheduler)
		.fork({ _ in
			XCTFail()
		}) { both in
			XCTAssert(both.0 == 1)
			XCTAssert(both.1 == 2)
			
			finish.fulfill()
		}
		
		scheduler.advance()
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testZipWith() {
		let scheduler = TestScheduler()

		let finish = expectation(description: "finish")
		
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)
		
		zip2(with: { ($0, $1) })(left, left2, scheduler)
		.fork({ e in
			XCTAssert(e == -2)
		}) { (_) in
			XCTFail()
		}
		
		zip2(with: { ($0, $1) })(left, right, scheduler)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip2(with: { ($0, $1) })(right, left, scheduler)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip2(with: { ($0, $1) })(right, right2, scheduler)
		.fork({ _ in
			XCTFail()
		}) { both in
			XCTAssert(both.0 == 1)
			XCTAssert(both.1 == 2)
			
			finish.fulfill()
		}
		
		scheduler.advance()
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testZip3AllFailed() {
		let scheduler = TestScheduler()

		let finish = expectation(description: "finish")
		
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let left3 = IO<Int, Int>.rejected(-3)
		
		zip3(left, left2, left3, scheduler)
		.fork({ e in
			XCTAssert(e == -1)
			finish.fulfill()
		}) { (_) in
			XCTFail()
		}
		
		scheduler.advance()
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testZip3OneOK() {
		let scheduler = TestScheduler()

		let finish = expectation(description: "finish")
		
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		
		zip3(left, left2, right, scheduler)
		.fork({ e in
			XCTAssert(e == -1)
			finish.fulfill()
		}) { (_) in
			XCTFail()
		}
		
		scheduler.advance()
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testZip3FirstOK() {
		let scheduler = TestScheduler()

		let finish = expectation(description: "finish")
		
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
				
		zip3(right, left, left2, scheduler)
		.fork({ e in
			XCTAssert(e == -2)
			finish.fulfill()
		}) { (_) in
			XCTFail()
		}
		
		scheduler.advance()
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testZip3AllOK() {
		let scheduler = TestScheduler()

		let finish = expectation(description: "finish")
		
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)
		let right3 = IO<Int, Int>.of(3)
		
		zip3(right, right2, right3, scheduler)
		.fork({ _ in
			XCTFail()
		}) { both in
			XCTAssert(both.0 == 1)
			XCTAssert(both.1 == 2)
			XCTAssert(both.2 == 3)
			
			finish.fulfill()
		}
		
		scheduler.advance()
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testZip3With() {
		let scheduler = TestScheduler()

		let finish = expectation(description: "finish")
		
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)
		
		zip3(with: { ($0, $1, $2) })(left, left, left2, scheduler)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		scheduler.advance()
		scheduler.advance()

		zip3(with: { ($0, $1, $2) })(left, right, right2, scheduler)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		scheduler.advance()
		scheduler.advance()
		
		zip3(with: { ($0, $1, $2) })(right, left, left2, scheduler)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		scheduler.advance()
		scheduler.advance()
		
		zip3(with: { ($0, $1, $2) })(right, right, right2, scheduler)
		.fork({ _ in
			XCTFail()
		}) { both in
			XCTAssert(both.0 == 1)
			XCTAssert(both.1 == 1)
			XCTAssert(both.2 == 2)
			
			finish.fulfill()
		}
		
		scheduler.advance()
		scheduler.advance()
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testZip4() {
		let scheduler = TestScheduler()

		let finish = expectation(description: "finish")
		
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)
		
		zip4(left, left2, left2, left, scheduler)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip4(left, left2, right, right2, scheduler)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip4(right, left, left2, right, scheduler)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip4(right, right, right2, right2, scheduler)
		.fork({ _ in
			XCTFail()
		}) { both in
			XCTAssert(both.0 == 1)
			XCTAssert(both.1 == 1)
			XCTAssert(both.2 == 2)
			XCTAssert(both.3 == 2)
			
			finish.fulfill()
		}
		
		scheduler.advance()
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testZip4With() {
		let scheduler = TestScheduler()

		let finish = expectation(description: "finish")
		
		let left = IO<Int, Int>.rejected(-1)
		let left2 = IO<Int, Int>.rejected(-2)
		let right = IO<Int, Int>.of(1)
		let right2 = IO<Int, Int>.of(2)
		
		zip4(with: { ($0, $1, $2, $3) })(left, left, left, left2, scheduler)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip4(with: { ($0, $1, $2, $3) })(left, right, right2, right, scheduler)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip4(with: { ($0, $1, $2, $3) })(right, left, left2, right, scheduler)
		.fork({ e in
			XCTAssert(e == -1)
		}) { (_) in
			XCTFail()
		}
		
		zip4(with: { ($0, $1, $2, $3) })(right, right, right2, right2, scheduler)
		.fork({ _ in
			XCTFail()
		}) { both in
			XCTAssert(both.0 == 1)
			XCTAssert(both.1 == 1)
			XCTAssert(both.2 == 2)
			XCTAssert(both.3 == 2)
			
			finish.fulfill()
		}
		
		scheduler.advance()
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	/// If one operation fails, the other one should be cancelled
	func testZipCancels() {
		let scheduler = TestScheduler()

		let cancelled = expectation(description: "cancelled")
		let finish = expectation(description: "finish")

		let left = IO<String, Int>.rejected("An error")
		let right = IO<String, Int> { _, _, _ in
		} cancel: {
			cancelled.fulfill()
		}
		
		zip(left, right, scheduler)
			.fork({ error in
				XCTAssertEqual(error, "An error")
				finish.fulfill()
			}, { _ in
				XCTFail("Should not succeed")
			}
		)
		
		scheduler.advance()
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
