//
//  BracketTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 03/07/2019.
//

import Foundation
import XCTest
import Sio

class BracketTests: XCTestCase {
	func testReleaseOnSuccess() {
		let release = expectation(description: "resource released")
		
		let task = UIO.of(1).delay(1).bracket({ _ in
			.effectMain { release.fulfill() }
		}, { value in
			UIO.of(value)
		})
		
		task.fork(absurd, { value in
			XCTAssert(value == 1)
		})
		
		waitForExpectations(timeout: 5, handler: nil)
	}
	
	func testReleaseOnError() {
		let release = expectation(description: "resource released")
		
		let task = IO<String, Int>.of(1).bracket({ _ in
			.effectMain { release.fulfill() }
		}, { value in
			IO<String, Int>.rejected("error").delay(1)
		})
		
		task.fork({ e in
			XCTAssert(e == "error")
		}, { value in
			XCTFail()
		})
		
		waitForExpectations(timeout: 2, handler: nil)
	}
	
//	func testReleaseOnCancellation() {
//		let release = expectation(description: "Resource released")
//
//		let task = UIO.of(1)
//		.tap { _ in UIO.effect { print("Resource acquired") } }
//		.bracket({ _ in
//			.effectMain {
//				print("resource released")
//				release.fulfill()
//			}
//		}, { value in
//			UIO.of(value).delay(1)
//		})
//
//		task.fork({ _ in
//			XCTFail()
//		}, { value in
//			XCTFail()
//		})
//
//		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//			task.cancel()
//		}
//
//		waitForExpectations(timeout: 2, handler: nil)
//	}
}
