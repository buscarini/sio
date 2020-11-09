//
//  ValueStoreIsoTests.swift
//  SioValueStoreTests
//
//  Created by José Manuel Sánchez Peñarroja on 19/12/2019.
//

import Foundation
import XCTest
import Sio
import SioValueStore

class SIOValueStoreIsoTests: XCTestCase {
	enum Left: String, Equatable {
		case a
		case b
	}
	
	enum Middle: Int, Equatable {
		case one
		case two
	}
	
	static var leftMiddle = Iso<Left, Middle>.init(from: { middle in
		switch middle {
		case .one:
			return .a
		case .two:
			return .b
		}
	}, to: { left in
		switch left {
		case .a:
			return .one
		case .b:
			return .two
		}
	})
	
	func testDimapRightOne() {
		let scheduler = TestScheduler()

		let vs = dimap(
			ValueStoreA<Void, String, Left>.of(.a),
			SIOValueStoreIsoTests.leftMiddle
		)
			
		vs
			.load
			.assert(.one, scheduler: scheduler)
	}
	
	func testDimapRightTwo() {
		let scheduler = TestScheduler()

		let vs = dimap(
			ValueStoreA<Void, String, Left>.of(.b),
			SIOValueStoreIsoTests.leftMiddle
		)
			
		vs
			.load
			.assert(.two, scheduler: scheduler)
	}
	
	func testComposeRightOne() {
		let scheduler = TestScheduler()

		let vs = ValueStoreA<Void, String, Left>.of(.a)
			>>> SIOValueStoreIsoTests.leftMiddle
			
		vs
			.load
			.assert(.one, scheduler: scheduler)
	}
	
	func testComposeRightTwo() {
		let scheduler = TestScheduler()

		let vs = ValueStoreA<Void, String, Left>.of(.b)
			>>> SIOValueStoreIsoTests.leftMiddle
			
		vs
			.load
			.assert(.two, scheduler: scheduler)
	}
	
	func testComposeRightIso() {
		let scheduler = TestScheduler()

		let saves = expectation(description: "saves")
		
		let vs = ValueStoreA<Void, String, Middle>.assertOnlySaves(saves, .one)
		
		
		(SIOValueStoreIsoTests.leftMiddle >>> vs)
			.save(.a)
			.assert(.one, scheduler: scheduler)
		
		waitForExpectations(timeout: 0.01, handler: nil)
	}

	func testComposeRightTwoIso() {
		let scheduler = TestScheduler()

		let saves = expectation(description: "saves")
		
		let vs = ValueStoreA<Void, String, Middle>.assertOnlySaves(saves, .two)
		
		(SIOValueStoreIsoTests.leftMiddle >>> vs)
			.save(.b)
			.assert(.two, scheduler: scheduler)
		
		waitForExpectations(timeout: 0.01, handler: nil)
	}
	
	func testComposeLeft() {
		let scheduler = TestScheduler()

		let vs = (SIOValueStoreIsoTests.leftMiddle.reversed <<< ValueStoreA<Void, String, Middle>.of(.one))
			
		vs
			.load
			.assert(.a, scheduler: scheduler)
	}
	
	func testComposeLeftTwo() {
		let scheduler = TestScheduler()

		let vs = (SIOValueStoreIsoTests.leftMiddle.reversed <<< ValueStoreA<Void, String, Middle>.of(.two))
			
		vs
			.load
			.assert(.b, scheduler: scheduler)
	}
	
	func testComposeLeftIso() {
		let scheduler = TestScheduler()

		let saves = expectation(description: "saves")
		
		let vs = ValueStoreA<Void, String, Middle>.assertOnlySaves(saves, .one)
		
		
		(vs <<< SIOValueStoreIsoTests.leftMiddle)
			.save(.a)
			.assert(.one, scheduler: scheduler)
		
		waitForExpectations(timeout: 0.01, handler: nil)
	}

	func testComposeLeftTwoIso() {
		let scheduler = TestScheduler()

		let saves = expectation(description: "saves")
		
		let vs = ValueStoreA<Void, String, Middle>.assertOnlySaves(saves, .two)
		
		(vs <<< SIOValueStoreIsoTests.leftMiddle)
			.save(.b)
			.assert(.two, scheduler: scheduler)
		
		waitForExpectations(timeout: 0.01, handler: nil)
	}
}

