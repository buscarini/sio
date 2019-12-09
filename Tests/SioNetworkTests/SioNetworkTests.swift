
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
		//	.map { $0.0 }
		//	.flatMap { a in
		//		SIO<Void, Void, String>
		//			.from(Codec.utf8.to(a))
		//			.mapError { _ in
		//				NetworkError.unknown
		//			}
		//	}
			.fork({ e in
				XCTFail()
			}) { result in
				print(result)
				
				finish.fulfill()
			}
		
		
		waitForExpectations(timeout: 5, handler: nil)
	}
}
