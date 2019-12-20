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
		let vs: ValueStoreA<Void, String, (Int, Int)> = zip(
			ValueStoreA<Void, String, Int>.of(1),
			ValueStoreA<Void, String, Int>.of(2)
		)
		
		vs
		.load
			.map { $0.0 + $0.1 }
			.assert(3)
	}	
}
