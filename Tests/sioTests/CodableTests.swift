//
//  CodableTests.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 29/11/2019.
//

import Foundation
import XCTest
import Sio

class CodableTests: XCTestCase {
	static let name = "Mary"
	static let age = 30
	
	
	enum TestError: Error {
		case data
	}
	
	struct User: Codable {
		var name: String
		var age: Int
	}
	
	func testDecode() {
		let raw = """
		{
			"name": "\(CodableTests.name)",
			"age": \(CodableTests.age)
		}
		"""
		
		let expectation = self.expectation(description: "data decoded")
		
		Task.of(raw)
			.flatMap { string in
				Task.from(string.data(using: .utf8), TestError.data)
			}
			.decode(User.self, decoder: JSONDecoder())
			.fork((), { error in
				XCTFail()
			},
			{ value in
				XCTAssert(value.name == CodableTests.name)
				XCTAssert(value.age == CodableTests.age)
				
				expectation.fulfill()
			})
		
		self.waitForExpectations(timeout: 1.0, handler: nil)
	}
	
	func testEncode() {
		let user = User(name: CodableTests.name, age: CodableTests.age)
		
		let expectation = self.expectation(description: "roundtrip")
		
		Task.of(user)
			.encode(encoder: JSONEncoder())
			.decode(User.self, decoder: JSONDecoder())
			.fork((), { error in
				XCTFail()
			},
			{ value in
				XCTAssert(value.name == CodableTests.name)
				XCTAssert(value.age == CodableTests.age)
				
				expectation.fulfill()
			})
			
		self.waitForExpectations(timeout: 1.0, handler: nil)

	}
}
