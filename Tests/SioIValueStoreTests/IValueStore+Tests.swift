//
//  ValueStore+Tests.swift
//  SioValueStoreTests
//
//  Created by José Manuel Sánchez Peñarroja on 19/12/2019.
//

import XCTest
import Foundation
import Sio
import SioIValueStore

public extension IValueStore where R == Void {
	static func assertOnlyLoads(
		_ expect: XCTestExpectation,
		_ value: B,
		file: StaticString = #file,
		line: UInt = #line
	) -> IValueStore {
		let vs = IValueStore.init(
			load: { _ in
				.init { _ in
					expect.fulfill()
					return .right(value)
				}
			},
			save: { _, toSave in
				XCTFail("Tried to save", file: file, line: line)
				return .of(value)
			},
			remove: { _ in
				.init { _ in
					XCTFail("Tried to remove", file: file, line: line)
					return .right(())
				}
			}
		)
		
		return vs
	}
}

public extension IValueStore where R == Void, A: Equatable, A == B {
	static func assertOnlySaves(
		_ expect: XCTestExpectation,
		_ value: A,
		file: StaticString = #file,
		line: UInt = #line
	) -> IValueStore {
		let vs = IValueStore.init(
			load: { _ in
				.init { _ in
					XCTFail("Tried to load", file: file, line: line)
					return .right(value)
				}
			},
			save: { _, toSave in
				XCTAssert(value == toSave)
				expect.fulfill()
				return .of(toSave)
			},
			remove: { _ in
				.init { _ in
					XCTFail("Tried to remove", file: file, line: line)
					return .right(())
				}
			}
		)
		
		return vs
	}
}
