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
	enum TestError: Error {
		case unknown
	}
	
	struct User {
		var name: String
	}
	
	func testLazy() {
		SIO<Void, String, String>.lazy("ok")
			.assert("ok")
	}
	
	func testRejectedLazy() {
		SIO<Void, String, String>.rejectedLazy("err")
			.assertErr("err")
	}
	
	func testFromFunc() {
		SIO<String, Never, Int>.fromFunc { $0.count }
			.provide("hello")
			.assert(5)
	}
	
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
		SIO<Void, Int, String>.of("ok").const("b")
			.assert("b")
	}
	
	func testFlip() {
		SIO<Void, String, Int>.rejected("ok").flip()
			.assert("ok")
	}
	
	func testFlipInverse() {
		SIO<Void, String, Int>.of(1).flip()
			.assertErr(1)
	}
	
	func testEitherLeft() {
		IO.from(Either<String, Int>.left("ok"))
			.assertErr("ok")
	}
	
	func testEitherRight() {
		IO.from(Either<String, Int>.right(1))
			.assert(1)
	}
	
	func testToEitherLeft() {
		IO<String, Int>.rejected("err")
			.either()
			.assert({ value in
				value.isLeft && value.left == "err"
			})
	}
	
	func testToEitherRight() {
		IO<String, Int>.of(1)
			.either()
			.assert({ value in
				value.isRight && value.right == 1
			})
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
	
	func testIgnore() {
		let finish = expectation(description: "finish tasks")
		
		SIO<Void, String, String>.rejected("err")
		.ignore()
		.fork({ value in
			XCTAssert(value == ())
			finish.fulfill()
		}, { _ in
			XCTFail()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testCatching() {
		let finish = expectation(description: "finish tasks")
		
		SIO<Void, Error, String>.init(catching: {
			throw TestError.unknown
		})
		.fork({ e in
			switch e {
			case TestError.unknown:
				break
			default:
				XCTFail()
			}
			
			finish.fulfill()
		}, { _ in
			XCTFail()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	// MARK: Effects
	func testOnFail() {
		let finish = expectation(description: "finish tasks")
		
		SIO<Void, String, String>.rejected("ok")
		.onFail(do: .effect {
			finish.fulfill()
		})
		.onSuccess(do: .effect {
			XCTFail()
		})
		.fork({ _ in
			
		}, { value in
			XCTFail()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testOnSuccess() {
		let finish = expectation(description: "finish tasks")
		
		SIO<Void, String, String>.lazy("ok")
		.onFail(do: .effect {
			XCTFail()
		})
		.onSuccess(do: .effect {
			finish.fulfill()
		})
		.fork({ _ in
			XCTFail()
		}, { value in
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testAccess() {
		let finish = expectation(description: "finish tasks")
		
		SIO<(Int, Int), Never, Int>.access { $0.0 }
			.provide((1, 2))
			.fork(absurd, { value in
				XCTAssert(value == 1)
				finish.fulfill()
			})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testAccessPath() {
		let finish = expectation(description: "finish tasks")
		
		access(\User.name)
			.provide(User.init(name: "john"))
			.fork(absurd, { value in
				XCTAssert(value == "john")
				finish.fulfill()
			})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testEmpty() {
		let finish = expectation(description: "finish tasks")
		
		SIO<Void, Never, Void>.empty
		.fork(absurd, { value in
			finish.fulfill()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testNever() {
		let finish = expectation(description: "finish tasks")
		
		SIO<Void, Never, Never>.never
		.fork(absurd, absurd)
		
		finish.fulfill()
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testRunError() {
		let finish = expectation(description: "finish tasks")
		
		SIO<Void, String, Int>.rejected("err")
			.onCompletion(.effect {
				finish.fulfill()
			})
			.run(()) { _ in
				XCTFail()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testRunForget() {
		let finish = expectation(description: "finish tasks")
		
		SIO<Void, String, Int>.of(1)
			.onCompletion(.effect {
				finish.fulfill()
			})
			.runForget(())
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testBiFlatMapError() {
		let finish = expectation(description: "finish tasks")
		
		SIO<Void, Int, Int>.rejected(1)
			.biFlatMap(IO<Never, String>.of("ok"))
			.fork(absurd) { value in
				XCTAssert(value == "ok")
				finish.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testBiFlatMapErrorToError() {
		let finish = expectation(description: "finish tasks")
		
		SIO<Void, Int, Int>.rejected(1)
			.biFlatMap(IO<String, Never>.rejected("ok"))
			.fork({ value in
				XCTAssert(value == "ok")
				finish.fulfill()
			}, absurd)
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testBiFlatMapSuccess() {
		let finish = expectation(description: "finish tasks")
		
		SIO<Void, Int, Int>.of(1)
			.biFlatMap(IO<Never, String>.of("ok"))
			.fork(absurd) { value in
				XCTAssert(value == "ok")
				finish.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testBiFlatMapSuccessToError() {
		let finish = expectation(description: "finish tasks")
		
		SIO<Void, Int, Int>.of(1)
			.biFlatMap(IO<Never, String>.of("ok"))
			.fork(absurd) { value in
				XCTAssert(value == "ok")
				finish.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
