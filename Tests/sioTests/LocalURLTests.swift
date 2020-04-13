//
//  LocalURLTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 20/09/2019.
//

import XCTest
@testable import Sio

class LocalURLTests: XCTestCase {
	func testInitAbsoluteFile() {
		let file = URL(fileURLWithPath: "/tmp/file", isDirectory: false)
		let local = FileURL.init(url: file)
		XCTAssert(local != nil)
	}
	
	func testInitFailAbsoluteFile() {
		let file = URL(fileURLWithPath: "/tmp/file", isDirectory: true)
		let local = FileURL.init(url: file)
		XCTAssert(local == nil)
	}
	
	func testInitAbsoluteFolder() {
		let file = URL(fileURLWithPath: "/tmp", isDirectory: true)
		let local = AbsoluteLocalURL<IsFolder>.init(url: file)
		XCTAssert(local != nil)
	}
	
	func testInitFailAbsoluteFolder() {
		let file = URL(fileURLWithPath: "/tmp", isDirectory: false)
		let local = AbsoluteLocalURL<IsFolder>.init(url: file)
		XCTAssert(local == nil)
	}
		
	func testJoinAbsoluteWithFolder() {
		let file = URL(fileURLWithPath: "/tmp", isDirectory: true)
		let root = AbsoluteLocalURL<IsFolder>.init(url: file)!

		let local = RelativeLocalURL<IsFolder>.init(rawValue: "var")

		let final = join(root, local)
		XCTAssert(final.rawValue.absoluteString.hasSuffix("/tmp/var"))
	}

	func testJoinAbsoluteWithFile() {
		let file = URL(fileURLWithPath: "/tmp", isDirectory: true)
		let root = AbsoluteLocalURL<IsFolder>.init(url: file)!

		let local = RelativeLocalURL<IsFile>.init(rawValue: "file")

		let final = root <> local
//		let result = file.appendingPathComponent(file2.path)
		XCTAssert(final.rawValue.absoluteString.hasSuffix("/tmp/file"))
	}

	func testJoinRelativeWithFolder() {
		let root = RelativeLocalURL<IsFolder>.init(rawValue: "tmp")
		let local = RelativeLocalURL<IsFolder>.init(rawValue: "var")

		let final = root <> local
		XCTAssert(final.rawValue == "tmp/var")
	}
	
	func testJoinRelativeWithFile() {
		let root = RelativeLocalURL<IsFolder>.init(rawValue: "tmp")
		let local = RelativeLocalURL<IsFile>.init(rawValue: "file")

		let final = root <> local
		
		XCTAssert(final.rawValue.hasSuffix("tmp/file"))
	}
	
	func testRelativeFromAbsolute() {
		let file = URL(fileURLWithPath: "/tmp", isDirectory: true)
		let root = AbsoluteLocalURL<IsFolder>.init(url: file)!

		let final = root <> RelativeLocalURL<IsFile>.init(rawValue: "file")
		let recovered = final.relativePath(root)
		
		XCTAssertEqual(recovered?.rawValue, "file")
	}
	
	func testRelativeFromWrongAbsolute() {
		let file = URL(fileURLWithPath: "/tmp", isDirectory: true)
		let root = AbsoluteLocalURL<IsFolder>.init(url: file)!

		let otherFile = URL(fileURLWithPath: "/var", isDirectory: true)
		let other = AbsoluteLocalURL<IsFolder>.init(url: otherFile)!

		let final = root <> RelativeLocalURL<IsFile>.init(rawValue: "file")
		
		let recovered = final.relativePath(other)
		
		XCTAssertNil(recovered?.rawValue)
	}
}

