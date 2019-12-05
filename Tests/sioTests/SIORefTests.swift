//
//  SIORefTests.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 04/12/2019.
//

import Foundation
import XCTest
import Sio

class SioRefTests: XCTestCase {
	func testRefGetFree() {
		let finish = expectation(description: "finish")
		
		let ref = Ref<Int>.init(1)
		
		get(SIO<Ref<Int>, Never, Void>.environment())
			.provide(ref)
			.fork(absurd) { (arg) in
				let (value, _) = arg
				XCTAssert(value == 1)
				XCTAssert(ref.state == 1)
				finish.fulfill()
			}
		
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testRefModifyFree() {
		let finish = expectation(description: "finish")
		
		let ref = Ref<Int>.init(1)
		
		modify(SIO<Ref<Int>, Never, Void>.environment())({ (value: Int) in
				value * 2
			})
			.get()
			.provide(ref)
			.fork(absurd) { (arg) in
				let (value, _) = arg
				XCTAssert(value == 2)
				XCTAssert(ref.state == 2)
				finish.fulfill()
			}
		
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testRefModify() {
		let finish = expectation(description: "finish")
		
		let ref = Ref<Int>.init(1)
		
		SIO<Ref<Int>, Never, Void>.environment()
			.modify { value in
				value * 2
			}
			.get()
			.provide(ref)
			.fork(absurd) { (arg) in
				let (value, _) = arg
				XCTAssert(value == 2)
				XCTAssert(ref.state == 2)
				finish.fulfill()
			}
		
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testRefSetFree() {
		let finish = expectation(description: "finish")
		
		let ref = Ref<Int>.init(1)
		
		set(SIO<Ref<Int>, Never, Void>.environment())(2)
			.get()
			.provide(ref)
			.fork(absurd) { (arg) in
				let (value, _) = arg
				XCTAssert(value == 2)
				XCTAssert(ref.state == 2)
				finish.fulfill()
			}
		
		
		waitForExpectations(timeout: 1, handler: nil)
	}
	
	func testRefSet() {
		let finish = expectation(description: "finish")
		
		let ref = Ref<Int>.init(1)
		
		SIO<Ref<Int>, Never, Void>.environment()
			.set(2)
			.get()
			.provide(ref)
			.fork(absurd) { (arg) in
				let (value, _) = arg
				XCTAssert(value == 2)
				XCTAssert(ref.state == 2)
				finish.fulfill()
			}
		
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
