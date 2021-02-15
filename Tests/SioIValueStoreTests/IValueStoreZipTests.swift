//
//  ValueStoreZipTests.swift
//  SioValueStoreTests
//
//  Created by José Manuel Sánchez Peñarroja on 20/12/2019.
//

import Foundation
import XCTest
import Sio
import SioIValueStore

class SIOIValueStoreZipTests: XCTestCase {
	func testLoad() {
		let scheduler = TestScheduler()
		
		let vs: IValueStoreA<Void, Int, Void, (Int, Int)> = zip(
			Ref<[Int: Int]>.init([1: 1]).iValueStore(),
			Ref<[Int: Int]>.init([1: 2]).iValueStore(),
			scheduler
		)
		
		vs
		.load(1)
		.assert(
			{ (both: (Int, Int)) -> Bool in
				both.0 == 1 && both.1 == 2
			},
			scheduler: scheduler
		)
	}
	
	func testSave() {
		let scheduler = TestScheduler()

		let vs: IValueStoreA<Void, Int, Void, (Int, Int)> = zip(
			Ref<[Int: Int]>.init([:]).iValueStore(),
			Ref<[Int: Int]>.init([:]).iValueStore(),
			scheduler
		)
		
		vs
		.save(1, (3, 4))
		.assert(
			{ (both: (Int, Int)) -> Bool in
				both.0 == 3 && both.1 == 4
			},
			scheduler: scheduler
		)
	}
}
