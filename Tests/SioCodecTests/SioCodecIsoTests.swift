//
//  SioCodecIsoTests.swift
//  SioCodecTests
//
//  Created by José Manuel Sánchez Peñarroja on 13/12/2019.
//

import Foundation
import XCTest

import Sio
import SioCodec

enum Left: String, Equatable, Codable {
	case a
	case b
}

enum Middle: Int, Equatable, Codable {
	case one
	case two
}

enum Right: Int, Equatable {
	case ready
	case loading
}

extension Iso where A == Left, B == Middle {
	static var leftMiddle = Iso<Left, Middle>.init(from: { middle in
		switch middle {
		case .one:
			return .a
		case .two:
			return .b
		}
	}) { left in
		switch left {
		case .a:
			return .one
		case .b:
			return .two
		}
	}
}

extension Iso where A == Middle, B == Right {
	static var middleRight = Iso<Middle, Right>.init(from: { right in
		switch right {
		case .ready:
			return .one
		case .loading:
			return .two
		}
	}) { middle in
		switch middle {
		case .one:
			return .ready
		case .two:
			return .loading
		}
	}
}

class SIOCodecIsoTests: XCTestCase {
	func testLift() {
		let codec = Codec.lift(Iso.leftMiddle)
		
		let a = codec.from(Middle.one)
		XCTAssertEqual(a.right, Left.a)
		
		let two = codec.to(Left.b)
		XCTAssertEqual(two.right, Middle.two)
	}
	
	func testCompose() {
		let leftM = Codec.lift(Iso.leftMiddle)
		let middleR = Iso.middleRight
		let codec = leftM >>> middleR
		
		XCTAssert(codec.to(.a).right == .ready)
		XCTAssert(codec.to(.b).right == .loading)
		XCTAssert(codec.from(.ready).right == .a)
		XCTAssert(codec.from(.loading).right == .b)
	}
	
	func testComposeFlipped() {
		let leftM = Codec.lift(Iso.leftMiddle)
		let middleR = Iso.middleRight
		let codec = middleR <<< leftM
		
		XCTAssert(codec.to(.a).right == .ready)
		XCTAssert(codec.to(.b).right == .loading)
		XCTAssert(codec.from(.ready).right == .a)
		XCTAssert(codec.from(.loading).right == .b)
	}
	
	func testIso() {
		let codec = Iso.leftMiddle.reversed >>> Codec<Error, Left, Data>.json
		let one = Middle.one
		
		let result = codec.to(one).flatMap(codec.from)
		
		XCTAssert(result.right == one)
	}
	
	func testIsoFlipped() {
		let codec = Codec<Error, Left, Data>.json <<< Iso.leftMiddle.reversed
		let one = Middle.one
		
		let result = codec.to(one).flatMap(codec.from)
		
		XCTAssert(result.right == one)
	}
}
