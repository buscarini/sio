import Foundation
import XCTest
import Sio

class ScheduleTests: XCTestCase {
	func testScheduleOn() {
		let finish = expectation(description: "finish tasks")

		DispatchQueue.global().async {
			SIO<Void, String, String>.init({ (_, _, resolve) in
				XCTAssert(Thread.isMainThread)
				resolve("ok")
			})
			.scheduleOn(DispatchQueue.main)
			.fork({ _ in
				XCTFail()
			}, { value in
				XCTAssert(value == "ok")
				finish.fulfill()
			})
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testForkOnGlobal() {
		let finish = expectation(description: "finish tasks")

		SIO<Void, String, String>.of("ok")
		.forkOn(.global())
		.fork({ _ in
			XCTFail()
		}, { value in
			XCTAssert(Thread.isMainThread == false)
			XCTAssert(value == "ok")
			finish.fulfill()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testForkGlobal() {
		let finish = expectation(description: "finish tasks")

		SIO<Void, String, String>.of("ok")
		.fork(in: .global(), { _ in
			XCTFail()
		}, { value in
			XCTAssert(Thread.isMainThread == false)
			XCTAssert(value == "ok")
			finish.fulfill()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testForkOnMain() {
		let finish = expectation(description: "finish tasks")

		SIO<Void, String, String>.of("ok")
		.scheduleOn(DispatchQueue.global())
		.forkOn(.main)
		.fork({ _ in
			XCTFail()
		}, { value in
			XCTAssert(Thread.isMainThread)
			XCTAssert(value == "ok")
			finish.fulfill()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testForkOnMainError() {
		let finish = expectation(description: "finish tasks")

		SIO<Void, String, String>.rejected("ok")
		.scheduleOn(DispatchQueue.global())
		.forkOn(.main)
		.fork({ value in
			XCTAssert(Thread.isMainThread)
			XCTAssert(value == "ok")
			finish.fulfill()
		}, { _ in
			XCTFail()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testForkMain() {
		let finish = expectation(description: "finish tasks")

		SIO<Void, String, String>.of("ok")
		.scheduleOn(DispatchQueue.global())
		.forkMain({ _ in
			XCTFail()
		}, { value in
			XCTAssert(Thread.isMainThread)
			XCTAssert(value == "ok")
			finish.fulfill()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testForkMainError() {
		let finish = expectation(description: "finish tasks")

		SIO<Void, String, String>.rejected("ok")
		.scheduleOn(DispatchQueue.global())
		.forkMain({ value in
			XCTAssert(Thread.isMainThread)
			XCTAssert(value == "ok")
			finish.fulfill()
		}, { _ in
			XCTFail()	
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
