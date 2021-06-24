//
//  Alternative.swift
//  sio-iOS Tests
//
//  Created by José Manuel Sánchez Peñarroja on 21/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import XCTest
import Sio

class Alternative: XCTestCase {
	func exampleError() -> Error {
		return NSError(domain: "tests", code: 1, userInfo: nil)
	}
	
	func testAlternative1() {
		let expectation = self.expectation(description: "task alternative first failed")
		
		(or(IO<Error, Int>.rejected(self.exampleError()), IO.of(22)))
			.fork({ error in
				XCTFail()
				},
				  { value in
					XCTAssert(value == 22)
					expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testAlternative2() {
		let expectation = self.expectation(description: "task alternative second failed")
		
		(or(IO.of(22), IO<Error, Int>.rejected(self.exampleError())))
			.fork({ error in
				XCTFail()
			},
				  { value in
					XCTAssert(value == 22)
					expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testAlternativeFail() {
		let expectation = self.expectation(description: "task all failed")
		
		(or(IO<Error, Int>.rejected(self.exampleError()), IO<Error, Int>.rejected(self.exampleError())))
			.fork({ error in
				expectation.fulfill()
			},
				  { value in
					XCTFail()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testAlternativeOp() {
		let expectation = self.expectation(description: "task alternative with operator")
		
		(IO<Error, Int>.rejected(self.exampleError()) <|> IO.of(22))
			.fork({ error in
				XCTFail()
			},
				  { value in
					XCTAssert(value == 22)
					expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testAlternativeOp3() {
		let expectation = self.expectation(description: "task alternative with operator 3 arguments")
		
		(IO<Error, Int>.rejected(self.exampleError()) <|> IO<Error, Int>.rejected(self.exampleError()) <|> IO.of(22))
			.fork({ error in
				XCTFail()
			},
				  { value in
					XCTAssert(value == 22)
					expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testFirstSuccess() {
		let expectation = self.expectation(description: "success")
		
		firstSuccess(
			IO.of(22),
			[
				IO<Error, Int>.rejected(self.exampleError())
			]
		)
			.fork({ error in
				XCTFail()
			},
			{ value in
				XCTAssert(value == 22)
				expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testFirstSuccessSecond() {
		let expectation = self.expectation(description: "success")
		
		firstSuccess(
			IO<Error, Int>.rejected(self.exampleError()),
			[
				IO.of(22)
			]
		)
			.fork({ error in
				XCTFail()
			},
			{ value in
				XCTAssert(value == 22)
				expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testFirstSuccessError() {
		let expectation = self.expectation(description: "success")
		
		firstSuccess(
			IO<Error, Int>.rejected(self.exampleError()),
			[
				IO<Error, Int>.rejected(self.exampleError())
			]
		)
			.fork({ error in
				expectation.fulfill()
			},
			{ value in
				XCTFail()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
}
