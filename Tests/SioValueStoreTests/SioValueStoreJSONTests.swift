import Foundation
import XCTest

import CombineSchedulers

import Sio
import SioValueStore

class SIOValueStoreJSONTests: XCTestCase {
	struct User: Equatable, Codable {
		var id: String
		var name: String
		var age: Int
		
		static var mock: User {
			return .init(id: "1", name: "John", age: 30)
		}
	}
	
	func testJSON() {
		let scheduler = DispatchQueue.test

		let store = ValueStoreA<Void, ValueStoreError, User>.jsonPreference("user")
		let user = User.mock
		
		store
		.save(user)
		.flatMap { user in
			store.load
		}
		.assert(user, scheduler: scheduler)
	}
	
	func testJSONRemove() {
		let store = ValueStoreA<Void, ValueStoreError, User>.jsonPreference("user")
		let user = User.mock
		
		let removed = expectation(description: "Removed")
		store
			.save(user)
			.flatMap { _ in
				store.remove
			}
			.run { _ in
				XCTAssertNil(UserDefaults.standard.value(forKey: "user"))
				removed.fulfill()
			}
		
		waitForExpectations(timeout: 0.1, handler: nil)
	}
}
