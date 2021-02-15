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
import SioIValueStore

class SIOIValueStoreArrayTests: XCTestCase {
	static let validKey = "a"
	
	static func arrayStore() -> IValueStoreA<Void, String, String, [Int]> {
		var store: [Int] = [1]
		
		return IValueStoreA<Void, String, String, [Int]>(
			load: { k in
				k == validKey ? .of(store) : .rejected("error")
			},
			save: { k, values in
				guard k == validKey else {
					return .rejected("error")
				}
				
				store = values
				return .of(store)
			},
			remove: { k in
				guard k == validKey else {
					return .rejected("error")
				}
				
				return .sync({ _ in
					store = []
					return .right(())
				})
			}
		)
	}
	
	func testPrepend() {
		let scheduler = TestScheduler()

		Self.arrayStore()
			.prepend(key: Self.validKey, 2)
			.assert([2, 1], scheduler: scheduler)
	}
	
	func testPrependUnique() {
		let scheduler = TestScheduler()

		Self.arrayStore()
			.prependUnique(key: Self.validKey, 1)
			.assert([1], scheduler: scheduler)
	}
	
	func testPrependUniqueRepeated() {
		let scheduler = TestScheduler()

		Self.arrayStore()
			.prependUnique(key: Self.validKey, 2)
			.assert([2, 1], scheduler: scheduler)
	}
	
	func testAppend() {
		let scheduler = TestScheduler()

		Self.arrayStore()
			.append(key: Self.validKey, 2)
			.assert([1, 2], scheduler: scheduler)
	}
	
	func testAppendUniqueRepeated() {
		let scheduler = TestScheduler()

		Self.arrayStore()
			.appendUnique(key: Self.validKey, 1)
			.assert([1], scheduler: scheduler)
	}
	
	func testAppendUnique() {
		let scheduler = TestScheduler()

		Self.arrayStore()
			.appendUnique(key: Self.validKey, 2)
			.assert([1, 2], scheduler: scheduler)
	}
	
	func testRemove() {
		let scheduler = TestScheduler()

		Self.arrayStore()
			.remove(key: Self.validKey, 1)
			.assert([], scheduler: scheduler)
	}
	
	func testLoadSingle() {
		let scheduler = TestScheduler()

		let store = IValueStoreA<Void, String, ValueStoreError, [Int]>.of([1,2,3])
		
		store
			.loadSingle(key: Self.validKey) { $0 % 2 == 0 }
			.assert(2, scheduler: scheduler)
	}
	
	func testFunctor() {
		let scheduler = TestScheduler()

		Self.arrayStore()
			.map { $0.count }
			.load(Self.validKey)
			.assert(1, scheduler: scheduler)
	}
	
	func testContravariantFunctor() {
		let scheduler = TestScheduler()

		Self.arrayStore()
			.pullback { (strings: [String]) in
				strings.map { $0.count }
			}
			.save(Self.validKey, [ "hello", "world" ])
			.assert([5, 5], scheduler: scheduler)
	}
}
