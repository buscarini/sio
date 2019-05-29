//
//  ApplicativeTests.swift
//  sio-iOS Tests
//
//  Created by José Manuel Sánchez Peñarroja on 26/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import Foundation
import XCTest
import sio

class ApplicativeTests: XCTestCase {
	func testMultZero() {
		let finish = expectation(description: "finish")

		let left = UIO.of(1)
		let right = UIO<Int>.zero
		
		zip(with: { _, _ in () })(left, right)
			.run({ _ in
				XCTFail()
			})
		
		wait(for: [finish], timeout: 1)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			finish.fulfill()
		}
	}
}
