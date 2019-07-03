//
//  SioCodecJSONTests.swift
//  SioCodecTests
//
//  Created by José Manuel Sánchez Peñarroja on 02/07/2019.
//

import Foundation
import XCTest
import Sio
import SioCodec

class SIOCodecJSONTests: XCTestCase {
	struct User: Equatable, Codable {
		var id: String
		var name: String
		var age: Int
		
		static var mock: User {
			return .init(id: "1", name: "John", age: 30)
		}
	}
	
	func testJSON() {
		let codec = Codec<Error, User, Data>.json
		let user = User.mock
		
		let result = codec.to(user).flatMap(codec.from)
		
		XCTAssert(result.right == user)
	}
}
