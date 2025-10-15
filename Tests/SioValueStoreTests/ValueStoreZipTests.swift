import Foundation
import XCTest

import CombineSchedulers

import Sio
import SioValueStore

class SIOValueStoreZipTests: XCTestCase {
	func testLoad() async {
		let scheduler = DispatchQueue.test
		
		let vs: ValueStoreA<Void, Void, (Int, Int)> = zip(
			await Ref<Int?>.init(1).valueStore(),
			await Ref<Int?>.init(2).valueStore(),
			scheduler
		)
		
		vs.load
			.assert(
				{ (both: (Int, Int)) -> Bool in
					both.0 == 1 && both.1 == 2
				},
				scheduler: scheduler
			)
	}
	
	func testSave() async {
		let scheduler = DispatchQueue.test
		
		let vs: ValueStoreA<Void, Void, (Int, Int)> = zip(
			await Ref<Int?>.init(nil).valueStore(),
			await Ref<Int?>.init(nil).valueStore(),
			scheduler
		)
		
		vs.save((3, 4))
			.assert(
				{ (both: (Int, Int)) -> Bool in
					both.0 == 3 && both.1 == 4
				},
				scheduler: scheduler
			)
	}
}
