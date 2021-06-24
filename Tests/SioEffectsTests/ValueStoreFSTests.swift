//
//  ValueStoreFSTests.swift
//  SioEffectsTests
//
//  Created by José Manuel Sánchez Peñarroja on 02/06/2020.
//

import Foundation
import XCTest

import Sio
import SioEffects
import SioValueStore
import SioCodec

class ValueStoreFSTests: XCTestCase {
	
	@available(OSX 10.12, *)
	func testData() {
		let finish = expectation(description: "finish")
		
		let fileName = RelativeLocalURL<IsFile>.init(rawValue: UUID().uuidString)
		
		let fileURL = PathUtils.tmpPath.append(fileName)
		
		let fs = FS()
		
		let data = Codec.utf8.to("hello").right!
		
		let store = ValueStore.fileData(fileURL)
		store.save(data)
		.flatMap { _ in
			store.load
		}
		.flatMap { data -> SIO<FS, Error, Void> in
			XCTAssert(
				FileManager.default.fileExists(atPath: fileURL.rawValue.path)
			)
			
			XCTAssertEqual(Codec.utf8.from(data).right, "hello")

			return store.remove
		}
		.provide(fs)
		.fork({ _ in
			XCTFail()
		}) { _ in
			finish.fulfill()
			
			XCTAssertFalse(
				FileManager.default.fileExists(atPath: fileURL.rawValue.path)
			)
		}
		
		waitForExpectations(timeout: 0.3, handler: nil)
	}
}
