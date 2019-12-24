//
//  SioCodecDateTests.swift
//  SioCodecTests
//
//  Created by José Manuel Sánchez Peñarroja on 23/12/2019.
//

import Foundation
import XCTest
import Sio
import SioCodec

class SIOCodecDateTests: XCTestCase {
	func testEpoch() {
		let codec = Codec<Error, Date, Double>.epochSeconds
		let date = Date.init(timeIntervalSince1970: 100)
		
		let result = codec.to(date).flatMap(codec.from)
		
		XCTAssert(result.right == date)
	}
	
	func testDF() {
		let df = DateFormatter()
		df.dateStyle = .long
		df.timeStyle = .long
		let codec = Codec<Error, Date, String>.dateFormatter(df)
		let date = Date.init(timeIntervalSince1970: 100)
		
		let result = codec.to(date).flatMap(codec.from)
		
		XCTAssert(result.right == date)
	}
}
