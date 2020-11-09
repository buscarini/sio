//
//  FSUtilsTests.swift
//  SioEffectsTests
//
//  Created by José Manuel Sánchez Peñarroja on 02/06/2020.
//

import Foundation
import Sio
import SioEffects
import XCTest

/*class FSUtilsTests: XCTestCase {
	func testReadBundleString() {
		let finish = expectation(description: "finish")
		let bundle = Bundle(for: type(of: self))
		
		FS()
			.readStr(bundle, name: "Resource", extension: "txt")
			.fork({ _ in
				XCTFail()
			}) { value in
				XCTAssertEqual(value, "hello")
				finish.fulfill()
			}
		
		waitForExpectations(timeout: 1, handler: nil)
	}
}
*/
