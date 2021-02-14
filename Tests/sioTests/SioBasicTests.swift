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
	
	func testCancellation() {
		let neverCalled = expectation(description: "inverse")
		neverCalled.isInverted = true
		
		let io = IO<String, String>.of("ok")
			
		io.cancel()
		
		io.fork({ _ in
			XCTFail()
			
			neverCalled.fulfill()
		}) { _ in
			
			XCTFail()
			
			neverCalled.fulfill()
		}
		
		waitForExpectations(timeout: 0.1, handler: nil)
	}
	
	func testLazy() {
		let scheduler = TestScheduler()
		SIO<Void, String, String>.lazy("ok")
			.assert("ok", scheduler: scheduler)
	}
	
	func testRejectedLazy() {
		let scheduler = TestScheduler()

		SIO<Void, String, String>.rejectedLazy("err")
			.assertErr("err", scheduler: scheduler)
	}
	
	func testFromFunc() {
		let scheduler = TestScheduler()

		SIO<String, Never, Int>.fromFunc { $0.count }
			.provide("hello")
			.assert(5, scheduler: scheduler)
	}
	
	func testFromFuncCancel() {
		let neverCalled = expectation(description: "inverse")
		neverCalled.isInverted = true

		
		let io = SIO<String, Never, Int>
			.fromFunc { (string: String) -> Int in
				neverCalled.fulfill()
				return string.count
			}
			.provide("hello")
			
		
		io.cancel()
		
		io
			.run { _ in
				neverCalled.fulfill()
				XCTFail()
			}
		
		waitForExpectations(timeout: 0.1, handler: nil)
	}
	
	func testVoid() {
		let finish = expectation(description: "finish tasks")

		SIO<Void, String, String>
			.of("ok")
			.void
			.fork({ _ in
				XCTFail()
			}, { value in
				XCTAssert(value == ())
				finish.fulfill()
			})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testConst() {
		let scheduler = TestScheduler()

		SIO<Void, Int, String>.of("ok").const("b")
			.assert("b", scheduler: scheduler)
	}
	
	func testConstError() {
		let scheduler = TestScheduler()

		SIO<Void, Int, String>.of("ok").constError(1)
			.assert("ok", scheduler: scheduler)
		
		SIO<Void, Int, String>.rejected(2).constError(1)
			.assertErr(1, scheduler: scheduler)
	}
	
	func testFlip() {
		let scheduler = TestScheduler()

		SIO<Void, String, Int>.rejected("ok").flip()
			.assert("ok", scheduler: scheduler)
	}
	
	func testFlipInverse() {
		let scheduler = TestScheduler()

		SIO<Void, String, Int>.of(1).flip()
			.assertErr(1, scheduler: scheduler)
	}
	
	func testEitherLeft() {
		let scheduler = TestScheduler()

		IO.from(Either<String, Int>.left("ok"))
			.assertErr("ok", scheduler: scheduler)
	}
	
	func testEitherRight() {
		let scheduler = TestScheduler()

		IO.from(Either<String, Int>.right(1))
			.assert(1, scheduler: scheduler)
	}
	
	func testToEitherLeft() {
		let scheduler = TestScheduler()

		IO<String, Int>.rejected("err")
			.either()
			.assert({ value in
				value.isLeft && value.left == "err"
			}, scheduler: scheduler)
	}
	
	func testToEitherRight() {
		let scheduler = TestScheduler()

		IO<String, Int>.of(1)
			.either()
			.assert({ value in
				value.isRight && value.right == 1
			}, scheduler: scheduler)
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
				.sync({ _ in
					.right(())
				})
			}, { value in
				.sync({ _ in
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
				.sync({ _ in
					tap.fulfill()
					return .right(())
				})
			}, { value in
				.sync({ _ in
					.right(())
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
	
	func testIgnoreErrors() {
		let finish = expectation(description: "finish tasks")
		finish.isInverted = true
		
		SIO<Void, String, String>.rejected("err")
		.ignoreErrors()
		.run { _ in }
		
		waitForExpectations(timeout: 0.1, handler: nil)
	}
	
	func testCatch() {
		let finish = expectation(description: "finish tasks")
		
		SIO<Void, String, String>.rejected("err")
		.catch("recovered")
		.fork({ _ in
			XCTFail()
		}, { value in
			XCTAssert(value == "recovered")
			
			finish.fulfill()
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
	
	func testRecoverErrors() {
		let finish = expectation(description: "Finish")
		
		let io = IO<Int, Void>.rejected(1)
		
		io.recoverErrors()
			.run { _ in
				finish.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	// MARK: Effects
	func testOnFail() {
		let finish = expectation(description: "finish tasks")
		
		SIO<Void, String, String>.rejected("ok")
		.onError(do: .effect {
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
		.onError(do: .effect {
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
		let scheduler = TestScheduler()

		let sio: SIO<(Int, Int), Never, Int> = SIO<(Int, Int), Never, Int>.access { $0.0 }
			
		sio
			.provide((1, 2))
			.assert(1, scheduler: scheduler)
	}
	
	func testAccessPath() {
		let scheduler = TestScheduler()

		let io: SIO<User, Void, String> = access(\User.name)
		io
			.provide(User.init(name: "john"))
			.assert("john", scheduler: scheduler)
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
		let scheduler = TestScheduler()

		SIO<Void, Int, Int>.rejected(1)
			.biFlatMap(IO<Never, String>.of("ok"))
			.assert("ok", scheduler: scheduler)
	}
	
	func testFlatMapError() {
		let scheduler = TestScheduler()

		IO<Int, Int>.rejected(1)
			.flatMapError(IO<Int, Int>.of(2))
			.assert(2, scheduler: scheduler)
	}
	
	func testBiFlatMapErrorToError() {
		let scheduler = TestScheduler()

		SIO<Void, Int, Int>.rejected(1)
			.biFlatMap(IO<String, Never>.rejected("ok"))
			.assertErr("ok", scheduler: scheduler)
	}
	
	func testFlatMapErrorToError() {
		let scheduler = TestScheduler()

		SIO<Void, Int, Int>.rejected(1)
			.flatMapError(IO<Int, Int>.rejected(2))
			.assertErr(2, scheduler: scheduler)
	}
	
	func testBiFlatMapSuccess() {
		let scheduler = TestScheduler()

		SIO<Void, Int, Int>.of(1)
			.biFlatMap(IO<Never, String>.of("ok"))
			.assert("ok", scheduler: scheduler)
	}
	
	func testBiFlatMapSuccessToError() {
		let scheduler = TestScheduler()

		SIO<Void, Int, Int>.of(1)
			.biFlatMap(IO<Never, String>.of("ok"))
		.assert("ok", scheduler: scheduler)
	}
	
	func testFlatMapNever() {
		let scheduler = TestScheduler()

		SIO<Void, Never, Int>.of(1)
			.flatMapNever { value in
				IO<Int, Int>.of(1 + value)
			}
			.assert(2, scheduler: scheduler)
	}
	
	func testFlatMapNeverError() {
		let scheduler = TestScheduler()

		SIO<Void, Never, Int>.of(1)
			.flatMapNever { value in
				IO<Int, Int>.rejected(3)
			}
			.assertErr(3, scheduler: scheduler)
	}
	
	func testFlatMapNeverIO() {
		let scheduler = TestScheduler()

		SIO<Void, Never, Int>.of(1)
			.flatMapNever(SIO<Int, Int, Int>.of(2))
			.assert(2, scheduler: scheduler)
	}
	
	func testFlatMapNeverErrorIO() {
		let scheduler = TestScheduler()

		SIO<Void, Never, Int>.of(1)
			.flatMapNever(
				SIO<Int, Int, Int>.rejected(3)
			)
			.assertErr(3, scheduler: scheduler)
	}
	
	func testRunAll() {
		let scheduler = TestScheduler()
		
		runAll([
			SIO<Void, Int, Int>.of(1),
			SIO<Void, Int, Int>.rejected(2),
			SIO<Void, Int, Int>.of(3),
			SIO<Void, Int, Int>.rejected(4)
		], AnyScheduler(scheduler))
		.assert([ 1, 3 ], scheduler: scheduler)
	}
}
