//
//  StackTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 16/08/2020.
//

import Foundation
import Foundation
import XCTest
import Sio

class StackTests: XCTestCase {
	
	func testStackLevelOfMultipleMap() {
		let expectation = self.expectation(description: "task chained")
		
		IO<Never, String>.of("blah")
			.map { string in
				string.count
			}
			.map { value in
				value + 1
			}
			.map { value in
				value + 1
			}
			.map { value in
				value + 1
			}
			.run { _ in
				XCTAssertEqual(Thread.callStackSymbols.count, 50)
								
				expectation.fulfill()
			}
		
		self.waitForExpectations(timeout: 0.1, handler: nil)
	}
	
	func testStackLevelSyncMultipleMap() {
		let expectation = self.expectation(description: "task chained")
		
		IO<Never, String>.sync {
				.right("blah")
			}
			.map { string in
				string.count
			}
			.map { value in
				value + 1
			}
			.map { value in
				value + 1
			}
			.map { value in
				value + 1
			}
			.run { _ in
				XCTAssertEqual(Thread.callStackSymbols.count, 50)
								
				expectation.fulfill()
			}
		
		self.waitForExpectations(timeout: 0.1, handler: nil)
	}
	
	func testStackLevelASyncMultipleMap() {
		let expectation = self.expectation(description: "task chained")
		
		IO<Never, String>({ _, reject, resolve in
			resolve("blah")
		})
		.map { string in
			string.count
		}
		.map { value in
			value + 1
		}
		.map { value in
			value + 1
		}
		.map { value in
			value + 1
		}
		.map { value in
			value + 1
		}
		.run { _ in
			XCTAssertEqual(Thread.callStackSymbols.count, 76)
							
			expectation.fulfill()
		}
		
		self.waitForExpectations(timeout: 0.1, handler: nil)
	}
	
	func testStackLevelOfFlatMap() {
		let expectation = self.expectation(description: "task chained")
		
		IO<Never, String>.of("blah")
			.flatMap({ string in
				SIO.of(string.count)
			})
			.run { _ in
				XCTAssertEqual(Thread.callStackSymbols.count, 63)
								
				expectation.fulfill()
			}
		
		self.waitForExpectations(timeout: 0.1, handler: nil)
	}
	
	func testStackLevelOfMultipleFlatMap() {
		let expectation = self.expectation(description: "task chained")
		
		IO<Never, String>.of("blah")
			.flatMap({ string in
				SIO.of(string.count)
			})
			.flatMap({ value in
				SIO.of(value + 1)
			})
			.flatMap({ value in
				SIO.of(value + 1)
			})
			.flatMap({ value in
				SIO.of(value + 1)
			})
			.run { _ in				
				XCTAssertEqual(Thread.callStackSymbols.count, 50)
								
				expectation.fulfill()
			}
		
		self.waitForExpectations(timeout: 0.1, handler: nil)
	}
	
	func testStackLevelASyncMultipleFlatMap() {
		let expectation = self.expectation(description: "task chained")
		
		IO<Never, String>({ _, reject, resolve in
			resolve("blah")
		})
		.flatMap { string in
			.of(string.count)
		}
		.flatMap { value in
			.of(value + 1)
		}
		.flatMap { value in
			.of(value + 1)
		}
		.flatMap { value in
			.of(value + 1)
		}
		.flatMap { value in
			.of(value + 1)
		}
		.flatMap { value in
			.of(value + 1)
		}
		.run { _ in
			XCTAssertEqual(Thread.callStackSymbols.count, 76)
							
			expectation.fulfill()
		}
		
		self.waitForExpectations(timeout: 0.1, handler: nil)
	}
}
