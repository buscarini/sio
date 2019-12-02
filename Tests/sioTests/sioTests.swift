//
//  sioTests.swift
//  sio
//
//  Created by José Manuel Sánchez on 19/5/19.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import XCTest
import Sio

class sioTests: XCTestCase {
	func testVoid() {
		let finish = expectation(description: "finish tasks")

		SIO<Void, String, String>.of("ok").void
			.fork({ _ in
			XCTFail()
		}, { value in
			XCTAssert(value == ())
			finish.fulfill()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testConst() {
		let finish = expectation(description: "finish tasks")

		SIO<Void, Int, String>.of("ok").const("b")
			.fork({ _ in
			XCTFail()
		}, { value in
			XCTAssert(value == "b")
			finish.fulfill()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testFlip() {
		let finish = expectation(description: "finish tasks")

		SIO<Void, String, Int>.rejected("ok").flip()
			.fork({ _ in
			XCTFail()
		}, { value in
			XCTAssert(value == "ok")
			finish.fulfill()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testFlipInverse() {
		let finish = expectation(description: "finish tasks")
		
		SIO<Void, String, Int>.of(1).flip().fork({ value in
			XCTAssert(value == 1)
			finish.fulfill()
		}, { _ in
			XCTFail()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testEitherLeft() {
		let finish = expectation(description: "finish tasks")
		
		IO.from(Either<String, Int>.left("ok")).fork({ value in
			XCTAssert(value == "ok")
			finish.fulfill()
		}) { _ in
			XCTFail()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testEitherRight() {
		let finish = expectation(description: "finish tasks")

		
		IO.from(Either<String, Int>.right(1)).fork({ _ in
			XCTFail()
		}) { value in
			XCTAssert(value == 1)
			finish.fulfill()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testOnCompletionError() {
		let finish = expectation(description: "error")
		
		let sio = SIO<Void, String, String>.rejected("err")
			.onCompletion(SIO.effect(finish.fulfill))
		
		sio.fork({ _ in
		}) { _ in
			XCTFail()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testOnCompletionSuccess() {
		let finish = expectation(description: "error")
		
		let sio = SIO<Void, String, String>.of("ok")
			.onCompletion(SIO.effect(finish.fulfill))
		
		sio.fork({ _ in
			XCTFail()
		}) { _ in
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testOnCancellationBeforeFork() {
		let finish = expectation(description: "error")
		
		let sio = SIO<Void, String, String>.of("ok").delay(1)
			.onCancellation(SIO.effect(finish.fulfill))
		
		sio.cancel()
		
		sio.fork({ _ in
			XCTFail()
		}) { _ in
			XCTFail()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testOnCancellationAfterFork() {
		let finish = expectation(description: "error")
		
		let sio = SIO<Void, String, String>.of("ok").delay(1)
			.onCancellation(SIO.effect(finish.fulfill))
		
		sio.fork({ _ in
			XCTFail()
		}) { _ in
			XCTFail()
		}
		
		sio.cancel()
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testOnTerminationError() {
		let finish = expectation(description: "error")
		
		let sio = SIO<Void, String, String>.rejected("err")
			.onTermination(SIO.effect(finish.fulfill))
		
		sio.fork({ _ in
		}) { _ in
			XCTFail()
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testOnTerminationSuccess() {
		let finish = expectation(description: "error")
		
		let sio = SIO<Void, String, String>.of("ok")
			.onTermination(SIO.effect(finish.fulfill))
		
		sio.fork({ _ in
			XCTFail()
		}) { _ in
		}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testOnTerminationCancel() {
		let finish = expectation(description: "error")
		
		let sio = SIO<Void, String, String>.of("ok").delay(1)
			.onTermination(SIO.effect(finish.fulfill))
		
		sio.fork({ _ in
			XCTFail()
		}) { _ in
			XCTFail()
		}
		
		sio.cancel()
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testTapA() {
		let tap = expectation(description: "tap")
		let finish = expectation(description: "finish tasks")

		SIO<Void, Int, String>.of("ok")
			.tapBoth({ value in
				.init({ _ in
					.right(())
				})
			}, { value in
				.init({ _ in
					tap.fulfill()
					return .right(())
				})
			})
			.fork({ _ in
				XCTFail()
			}, { value in
				XCTAssert(value == "ok")
				finish.fulfill()
			})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testTapE() {
		let tap = expectation(description: "tap")
		let finish = expectation(description: "finish tasks")

		SIO<Void, Int, String>.rejected(1)
			.tapBoth({ value in
				.init({ _ in
					tap.fulfill()
					return .right(())
				})
			}, { value in
				.init({ _ in
					return .right(())
				})
			})
			.fork({ value in
				XCTAssert(value == 1)
				finish.fulfill()
			}, { _ in
				XCTFail()
			})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
