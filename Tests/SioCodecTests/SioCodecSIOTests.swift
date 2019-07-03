//
//  SioCodecSIOTests.swift
//  SioCodecTests
//
//  Created by José Manuel Sánchez Peñarroja on 03/07/2019.
//

import Foundation
import XCTest
import Sio
import SioCodec

class SIOCodecSIOTests: XCTestCase {
	func testSIO() {
		let finish = expectation(description: "finish ok")
		
		let origin = "Blah"
		
		let codec = Codec<Void, String, String>.base64
		
		let task = SIO<Void, Void, String>.of(origin)
		let encoded = task >>> codec
		
		encoded.fork({ _ in
			XCTFail()
		}, { string in
			XCTAssert(string == "QmxhaA==")
			
			finish.fulfill()
		})
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
