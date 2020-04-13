//
//  ValueStoreArrayTests.swift
//  SioValueStoreTests
//
//  Created by José Manuel Sánchez Peñarroja on 14/12/2019.
//

import Foundation
import XCTest
import Sio
import SioValueStore

class SIOValueStoreArrayTests: XCTestCase {
	static func arrayStore() -> ValueStoreA<Void, String, [Int]> {
		var store: [Int] = [1]
		
		return ValueStoreA<Void, String, [Int]>(
			load: .of(store),
			save: { values in
				store = values
				return .of(store)
			},
			remove: .sync({ _ in
				store = []
				return .right(())
			})
		)
	}
	
	func testPrepend() {
		SIOValueStoreArrayTests.arrayStore()
			.prepend(2)
			.assert([2, 1])
	}
	
	func testPrependUnique() {
		SIOValueStoreArrayTests.arrayStore()
			.prependUnique(1)
			.assert([1])
	}
	
	func testPrependUniqueRepeated() {
		SIOValueStoreArrayTests.arrayStore()
			.prependUnique(2)
			.assert([2, 1])
	}
	
	func testAppend() {
		SIOValueStoreArrayTests.arrayStore()
			.append(2)
			.assert([1, 2])
	}
	
	func testAppendUniqueRepeated() {
		SIOValueStoreArrayTests.arrayStore()
			.appendUnique(1)
			.assert([1])
	}
	
	func testAppendUnique() {
		SIOValueStoreArrayTests.arrayStore()
			.appendUnique(2)
			.assert([1, 2])
	}
	
	func testRemove() {
		SIOValueStoreArrayTests.arrayStore()
			.remove(1)
			.assert([])
	}
}
