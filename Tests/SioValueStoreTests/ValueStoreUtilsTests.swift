import Foundation
import XCTest
import Sio
import SioValueStore

class SIOValueStoreUtilsTests: XCTestCase {
	@MainActor
	func testMigration() async throws {
		let sourceRef = Ref<Int?>.init(6)
		let targetRef = Ref<Int?>.init(nil)
		
		let origin = await sourceRef.valueStore()
		let target = await targetRef.valueStore()
		
		let value = try await target.migrate(from: origin).constError(SIOError.empty).task
		
		let sourceValue = await sourceRef.value()
		XCTAssertNil(sourceValue)
		XCTAssertEqual(value, 6)
		
		let targetValue = await targetRef.value()
		XCTAssertEqual(targetValue, 6)
	}
}
