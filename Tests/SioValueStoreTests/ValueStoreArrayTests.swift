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
		let scheduler = DispatchQueue.test

		SIOValueStoreArrayTests.arrayStore()
			.prepend(2)
			.assert([2, 1], scheduler: scheduler)
	}
	
	func testPrependUnique() {
		let scheduler = DispatchQueue.test

		SIOValueStoreArrayTests.arrayStore()
			.prependUnique(1)
			.assert([1], scheduler: scheduler)
	}
	
	func testPrependUniqueRepeated() {
		let scheduler = DispatchQueue.test

		SIOValueStoreArrayTests.arrayStore()
			.prependUnique(2)
			.assert([2, 1], scheduler: scheduler)
	}
	
	func testAppend() {
		let scheduler = DispatchQueue.test

		SIOValueStoreArrayTests.arrayStore()
			.append(2)
			.assert([1, 2], scheduler: scheduler)
	}
	
	func testAppendUniqueRepeated() {
		let scheduler = DispatchQueue.test

		SIOValueStoreArrayTests.arrayStore()
			.appendUnique(1)
			.assert([1], scheduler: scheduler)
	}
	
	func testAppendUnique() {
		let scheduler = DispatchQueue.test

		SIOValueStoreArrayTests.arrayStore()
			.appendUnique(2)
			.assert([1, 2], scheduler: scheduler)
	}
	
	func testRemove() {
		let scheduler = DispatchQueue.test

		SIOValueStoreArrayTests.arrayStore()
			.remove(1)
			.assert([], scheduler: scheduler)
	}
	
	func testLoadSingle() {
		let scheduler = DispatchQueue.test

		let store = ValueStoreA<Void, ValueStoreError, [Int]>.of([1,2,3])
		
		store
			.loadSingle { $0 % 2 == 0 }
			.assert(2, scheduler: scheduler)
	}
	
	func testFunctor() {
		let scheduler = DispatchQueue.test

		SIOValueStoreArrayTests.arrayStore()
			.map { $0.count }
			.load
			.assert(1, scheduler: scheduler)
	}
	
	func testContravariantFunctor() {
		let scheduler = DispatchQueue.test

		SIOValueStoreArrayTests.arrayStore()
			.pullback { (strings: [String]) in
				strings.map { $0.count }
			}
			.save([ "hello", "world" ])
			.assert([5, 5], scheduler: scheduler)
	}
}
