//
//  ValueStoreZipTests.swift
//  SioValueStoreTests
//
//  Created by José Manuel Sánchez Peñarroja on 20/12/2019.
//

import Foundation
import XCTest
import Sio
import SioValueStore

class SIOValueStoreZipTests: XCTestCase {
	func testLoad() {
		let vs: ValueStoreA<Void, Void, (Int, Int)> = zip(
			Ref<Int?>.init(1).valueStore(),
			Ref<Int?>.init(2).valueStore()
		)
		
		vs
		.load
		.assert({ (both: (Int, Int)) -> Bool in
			both.0 == 1 && both.1 == 2
		})
	}
	
	func testSave() {
		let vs: ValueStoreA<Void, Void, (Int, Int)> = zip(
			Ref<Int?>.init(nil).valueStore(),
			Ref<Int?>.init(nil).valueStore()
		)
		
		vs
		.save((3, 4))
		.assert({ (both: (Int, Int)) -> Bool in
			both.0 == 3 && both.1 == 4
		})
	}
}
