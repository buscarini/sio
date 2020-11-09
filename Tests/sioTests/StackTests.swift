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
		let first = self.expectation(description: "first task")
		let second = self.expectation(description: "second task")
		
		var firstStackCount: Int?
		var secondStackCount: Int?
		
		IO<Never, String>.sync {
				.right("blah")
			}
			.map { string in
				string.count
			}
			.run { _ in
				firstStackCount = Thread.callStackSymbols.count
				
				first.fulfill()
			}
			
			
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
				secondStackCount = Thread.callStackSymbols.count

				second.fulfill()
			}
		
		self.waitForExpectations(timeout: 0.1, handler: { _ in
			XCTAssertNotNil(firstStackCount)
			XCTAssertEqual(firstStackCount, secondStackCount)
		})
	}
	
	func testStackLevelASyncMultipleMap() {
		let first = self.expectation(description: "first task")
		let second = self.expectation(description: "second task")
		
		var firstStackCount: Int?
		var secondStackCount: Int?

		IO<Never, String>({ _, reject, resolve in
			resolve("blah")
		})
		.map { string in
			string.count
		}
		.run { _ in
			firstStackCount = Thread.callStackSymbols.count
			
			first.fulfill()
		}
		
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
			secondStackCount = Thread.callStackSymbols.count

			second.fulfill()
		}
		
		self.waitForExpectations(timeout: 0.1, handler: { _ in
			XCTAssertNotNil(firstStackCount)
			XCTAssertEqual(firstStackCount, secondStackCount)
		})
	}
	
	func testStackLevelOfMultipleFlatMap() {
		let first = self.expectation(description: "first task")
		let second = self.expectation(description: "second task")
		
		var firstStackCount: Int?
		var secondStackCount: Int?

		
		IO<Never, String>.of("blah")
		.flatMap({ string in
			SIO.of(string.count)
		})
		.run { _ in
			firstStackCount = Thread.callStackSymbols.count
			
			first.fulfill()
		}
		
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
				secondStackCount = Thread.callStackSymbols.count

				second.fulfill()
			}
		
		self.waitForExpectations(timeout: 0.1, handler: { _ in
			XCTAssertNotNil(firstStackCount)
			XCTAssertEqual(firstStackCount, secondStackCount)
		})	}
	
	/*func testStackLevelASyncMultipleFlatMap() {
		let first = self.expectation(description: "first task")
		let second = self.expectation(description: "second task")
		
		var firstStackCount: Int?
		var secondStackCount: Int?

		IO<Never, String>({ _, reject, resolve in
			resolve("blah")
		})
		.flatMap { string in
			.of(string.count)
		}
		.run { _ in
			firstStackCount = Thread.callStackSymbols.count
			
			first.fulfill()
		}
		
		IO<Never, String>({ _, reject, resolve in
			resolve("blah")
		})
		.flatMap { string in
			IO.of(string.count)
		}
		.flatMap { value in
			IO.of(value + 1)
		}
		.flatMap { value in
			IO.of(value + 1)
		}
		.flatMap { value in
			IO.of(value + 1)
		}
		.flatMap { value in
			IO.of(value + 1)
		}
		.flatMap { value in
			IO.of(value + 1)
		}
		.run { _ in
			secondStackCount = Thread.callStackSymbols.count

			second.fulfill()
		}
		
		self.waitForExpectations(timeout: 0.1, handler: { _ in
			XCTAssertNotNil(firstStackCount)
			XCTAssertEqual(firstStackCount, secondStackCount)
		})
	}*/
}
