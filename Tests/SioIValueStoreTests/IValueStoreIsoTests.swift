import Foundation
import XCTest

import CombineSchedulers

import Sio
import SioIValueStore

class SIOIValueStoreIsoTests: XCTestCase {
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
		let scheduler = DispatchQueue.test

		let vs = dimap(
			IValueStoreA<Void, Int, String, Left>.of(.a),
			Self.leftMiddle
		)
			
		vs
			.load(1)
			.assert(.one, scheduler: scheduler)
	}
	
	func testDimapRightTwo() {
		let scheduler = DispatchQueue.test

		let vs = dimap(
			IValueStoreA<Void, Int, String, Left>.of(.b),
			Self.leftMiddle
		)
			
		vs
			.load(1)
			.assert(.two, scheduler: scheduler)
	}
	
	func testComposeRightOne() {
		let scheduler = DispatchQueue.test

		let vs = IValueStoreA<Void, Int, String, Left>.of(.a)
			>>> Self.leftMiddle
			
		vs
			.load(1)
			.assert(.one, scheduler: scheduler)
	}
	
	func testComposeRightTwo() {
		let scheduler = DispatchQueue.test

		let vs = IValueStoreA<Void, Int, String, Left>.of(.b)
			>>> Self.leftMiddle
			
		vs
			.load(1)
			.assert(.two, scheduler: scheduler)
	}
	
	func testComposeRightIso() {
		let scheduler = DispatchQueue.test

		let saves = expectation(description: "saves")
		
		let vs = IValueStoreA<Void, Int, String, Middle>.assertOnlySaves(saves, .one)
		
		
		(Self.leftMiddle >>> vs)
			.save(1, .a)
			.assert(.one, scheduler: scheduler)
		
		waitForExpectations(timeout: 0.01, handler: nil)
	}

	func testComposeRightTwoIso() {
		let scheduler = DispatchQueue.test

		let saves = expectation(description: "saves")
		
		let vs = IValueStoreA<Void, Int, String, Middle>.assertOnlySaves(saves, .two)
		
		(Self.leftMiddle >>> vs)
			.save(1, .b)
			.assert(.two, scheduler: scheduler)
		
		waitForExpectations(timeout: 0.01, handler: nil)
	}
	
	func testComposeLeft() {
		let scheduler = DispatchQueue.test

		let vs = (Self.leftMiddle.reversed <<< IValueStoreA<Void, Int, String, Middle>.of(.one))
			
		vs
			.load(1)
			.assert(.a, scheduler: scheduler)
	}
	
	func testComposeLeftTwo() {
		let scheduler = DispatchQueue.test

		let vs = (Self.leftMiddle.reversed <<< IValueStoreA<Void, Int, String, Middle>.of(.two))
			
		vs
			.load(1)
			.assert(.b, scheduler: scheduler)
	}
	
	func testComposeLeftIso() {
		let scheduler = DispatchQueue.test

		let saves = expectation(description: "saves")
		
		let vs = IValueStoreA<Void, Int, String, Middle>.assertOnlySaves(saves, .one)
		
		
		(vs <<< Self.leftMiddle)
			.save(1, .a)
			.assert(.one, scheduler: scheduler)
		
		waitForExpectations(timeout: 0.01, handler: nil)
	}

	func testComposeLeftTwoIso() {
		let scheduler = DispatchQueue.test

		let saves = expectation(description: "saves")
		
		let vs = IValueStoreA<Void, Int, String, Middle>.assertOnlySaves(saves, .two)
		
		(vs <<< Self.leftMiddle)
			.save(1, .b)
			.assert(.two, scheduler: scheduler)
		
		waitForExpectations(timeout: 0.01, handler: nil)
	}
}

