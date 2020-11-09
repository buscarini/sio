//
//  Sio+Tests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 13/12/2019.
//

import Foundation
import XCTest

import Sio

public extension SIO where R == Void {
	func assert(
		_ check: @escaping (A) -> Bool,
		scheduler: TestScheduler?,
		timeout: TimeInterval = 0.01,
		prepare: (() -> Void)? = nil,
		file: StaticString = #file,
		line: UInt = #line
	) {
		let finish = XCTestExpectation(description: "finish")
		
		self.fork({ _ in
			XCTFail("Effect failed", file: file, line: line)
		}) { result in
			if check(result) == false {
				XCTFail("check failed", file: file, line: line)
			}
			finish.fulfill()
		}
		
		let advance = prepare ?? { scheduler?.advance() }
		advance()
		
		if XCTWaiter.wait(for: [finish], timeout: timeout) != .completed {
			XCTFail("Effect didn't finish before timeout", file: file, line: line)
		}
	}
}

public extension SIO where A: Equatable, R == Void {
	func assert(
		_ value: A,
		scheduler: TestScheduler?,
		timeout: TimeInterval = 0.01,
		prepare: (() -> Void)? = nil,
		file: StaticString = #file,
		line: UInt = #line
	) {
		let finish = XCTestExpectation(description: "finish")
		
		self.fork({ _ in
			XCTFail("Effect failed", file: file, line: line)
		}) { result in
			XCTAssertEqual(result, value, file: file, line: line)
			finish.fulfill()
		}
		
		let advance = prepare ?? { scheduler?.advance() }
		advance()
		
		if XCTWaiter.wait(for: [finish], timeout: timeout) != .completed {
			XCTFail("Effect didn't finish before timeout", file: file, line: line)
		}
	}
}

public extension SIO where E: Equatable, R == Void {
	func assertErr(
		_ error: E,
		scheduler: TestScheduler?,
		prepare: (() -> Void)? = nil,
		timeout: TimeInterval = 0.01,
		file: StaticString = #file,
		line: UInt = #line
	) {
		let finish = XCTestExpectation(description: "finish")
		
		self.fork({ e in
			XCTAssertEqual(error, e, file: file, line: line)
			finish.fulfill()
		}) { result in
			XCTFail("Effect didn't fail", file: file, line: line)
		}
		
		let advance = prepare ?? { scheduler?.advance() }
		advance()

		if XCTWaiter.wait(for: [finish], timeout: timeout) != .completed {
			XCTFail("Effect didn't finish before timeout", file: file, line: line)
		}
	}
}
