import Foundation
import XCTest

import CombineSchedulers

import Sio
import SioIValueStore

class SIOIValueStoreZipTests: XCTestCase {
	func testLoad() async {
		let scheduler = DispatchQueue.test
		
		let left = await Ref<[Int: Int]>([1: 1]).iValueStore()
		let right = await Ref<[Int: Int]>([1: 2]).iValueStore()
		
		let vs: IValueStoreA<Void, Int, Void, (Int, Int)> = zip(
			left,
			right,
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
	
	func testSave() async {
		let scheduler = DispatchQueue.test

		let vs: IValueStoreA<Void, Int, Void, (Int, Int)> = zip(
			await Ref<[Int: Int]>([:]).iValueStore(),
			await Ref<[Int: Int]>([:]).iValueStore(),
			scheduler
		)
		
		vs.save(1, (3, 4))
		.assert(
			{ (both: (Int, Int)) -> Bool in
				both.0 == 3 && both.1 == 4
			},
			scheduler: scheduler
		)
	}
}
