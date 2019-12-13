
import Foundation
import XCTest

import Sio
import SioEffects
import SioCodec
import SioNetwork

class SIONetworkTests: XCTestCase {
	func testGet() {
		let finish = expectation(description: "finish")
		
		Network()
			.get("https://postman-echo.com/get")
			.fork({ e in
				XCTFail()
			}) { result in
				print(result)
				
				finish.fulfill()
			}
		
		
		waitForExpectations(timeout: 5, handler: nil)
	}
}
