//
//  ResultTests.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 30/11/2019.
//

import Foundation
import XCTest
import Sio

class ResultTests: XCTestCase {
	enum TestError: Error {
		case unknown
	}
	
	func testFrom() {
		let fail = expectation(description: "failed")
		let ok = expectation(description: "ok")
		
		let failure = Result<Int, TestError>.failure(.unknown)
		let success = Result<Int, TestError>.success(1)
		
		let sioF = IO.from(failure)
		let sioS = IO.from(success)
		
		sioF.fork({ e in
			XCTAssert(e == .unknown)
			fail.fulfill()
		}, { _ in
			XCTFail()
		})
		
		sioS.fork({ _ in
			XCTFail()
		}) { value in
			XCTAssert(value == 1)
			ok.fulfill()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testTo() {
		let fail = expectation(description: "failed")
		let ok = expectation(description: "ok")

		
		let err = IO<TestError, Int>.rejected(.unknown)
		let succ = IO<TestError, Int>.of(1)
		
		err.result().fork(absurd) { result in
			switch result {
			case let .failure(e):
				XCTAssert(e == .unknown)
				fail.fulfill()
			case .success:
				XCTFail()
			}
		}
		
		succ.result().fork(absurd) { result in
			switch result {
			case .failure:
				XCTFail()
			case let .success(value):
				XCTAssert(value == 1)
				ok.fulfill()
			}
		}
		
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
