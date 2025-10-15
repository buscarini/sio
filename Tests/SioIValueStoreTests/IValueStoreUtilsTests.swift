import Foundation
import XCTest
import Sio
import SioIValueStore

class SIOIValueStoreUtilsTests: XCTestCase {
	func testMigration() async throws {
		let sourceRef = Ref<[String: Int]>.init(["key": 6])
		let targetRef = Ref<[String: Int]>.init([:])
		
		let origin = await sourceRef.iValueStore()
		let target = await targetRef.iValueStore()
		
		let value = try await target.migrate(from: origin, key: "key").constError(SIOError.empty).task
		let source = await sourceRef.value()
		XCTAssertEqual(source, [:])
		XCTAssertEqual(value, 6)
		
		let targetValue = await targetRef.value()
		XCTAssertEqual(targetValue, ["key": 6])
	}
}
