import Foundation
import XCTest

import CombineSchedulers

import Sio
import SioValueStore

class SIOValueStoreZipTests: XCTestCase {
	@MainActor
	func testLoad() async throws {
		let scheduler = DispatchQueue.test
		
		let vs: ValueStoreA<Void, Void, (Int, Int)> = zip(
			await Ref<Int?>.init(1).valueStore(),
			await Ref<Int?>.init(2).valueStore(),
			scheduler
		)
		
		try await vs
			.load.constError(SIOError.empty)
			.assert(
				{ (both: (Int, Int)) -> Bool in
					both.0 == 1 && both.1 == 2
				},
				scheduler: scheduler
			)
	}
	
	@MainActor
	func testSave() async throws {
		let scheduler = DispatchQueue.test
		
		let vs: ValueStoreA<Void, Void, (Int, Int)> = zip(
			await Ref<Int?>.init(nil).valueStore(),
			await Ref<Int?>.init(nil).valueStore(),
			scheduler
		)
		
		try await vs
			.save((3, 4)).constError(SIOError.empty)
			.assert(
				{ (both: (Int, Int)) -> Bool in
					both.0 == 3 && both.1 == 4
				},
				scheduler: scheduler
			)
	}
}
