//
//  IsoTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 30/11/2019.
//

import Foundation
import XCTest
import Sio

class IsoTests: XCTestCase {
	enum Left: String, Equatable {
		case a
		case b
	}
	
	enum Middle: Int, Equatable {
		case one
		case two
	}
	
	enum Right: Int, Equatable {
		case ready
		case loading
	}
	
	func test() {
		let iso = Iso<Left, Middle>.init(from: { middle in
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
		
		let iso2 = Iso<Middle, Right>.init(from: { right in
			switch right {
			case .ready:
				return .one
			case .loading:
				return .two
			}
		}, to: { middle in
			switch middle {
			case .one:
				return .ready
			case .two:
				return .loading
			}
		})
		
		let final = iso >>> iso2
		
		XCTAssert(final.from(.ready) == .a)
		XCTAssert(final.from(.loading) == .b)
		
		XCTAssert(final.to(.a) == .ready)
		XCTAssert(final.to(.b) == .loading)
		
		
		let reversed = iso2 <<< iso
		
		XCTAssert(reversed.from(.ready) == .a)
		XCTAssert(reversed.from(.loading) == .b)
		
		XCTAssert(reversed.to(.a) == .ready)
		XCTAssert(reversed.to(.b) == .loading)	
	}
}

