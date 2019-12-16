
import Foundation
import XCTest

import Sio
import SioEffects
import SioCodec
import SioNetwork

class SIONetworkTests: XCTestCase {
	func testGet() {
		let urlString = "https://postman-echo.com/get"
		
		let req = Network()
			.getRequest(urlString)
			
		XCTAssertNotNil(req)
		XCTAssertEqual(req?.url.rawValue.absoluteString, urlString)
		XCTAssertEqual(req?.method, .get)
		XCTAssertEqual(req?.successCodes, 200..<299)
	}
}
