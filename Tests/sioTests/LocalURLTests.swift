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

	func testInitRelativeFile() {
		let file = URL(fileURLWithPath: "file", isDirectory: false)
		let local = LocalURL<IsRelative, IsFile>.init(url: file)
		XCTAssert(local != nil)
	}
	
	func testInitFailRelativeFile() {
		let file = URL(fileURLWithPath: "file", isDirectory: true)
		let local = LocalURL<IsRelative, IsFile>.init(url: file)
		XCTAssert(local == nil)
	}
	
	func testInitRelativeFile2() {
		let file = URL(
			fileURLWithPath: "file",
			isDirectory: false,
			relativeTo: URL(
				fileURLWithPath: "/tmp",
				isDirectory: true
			)
		)
		let local = LocalURL<IsRelative, IsFile>.init(url: file)
		XCTAssert(local != nil)
	}
	
	func testInitAbsoluteFolder() {
		let file = URL(fileURLWithPath: "/tmp", isDirectory: true)
		let local = LocalURL<IsAbsolute, IsFolder>.init(url: file)
		XCTAssert(local != nil)
	}
	
	func testInitFailAbsoluteFolder() {
		let file = URL(fileURLWithPath: "/tmp", isDirectory: false)
		let local = LocalURL<IsAbsolute, IsFolder>.init(url: file)
		XCTAssert(local == nil)
	}
	
	func testInitRelativeFolder() {
		let file = URL(fileURLWithPath: "tmp", isDirectory: true)
		let local = LocalURL<IsRelative, IsFolder>.init(url: file)
		XCTAssert(local != nil)
	}
	
	func testInitFailRelativeFolder() {
		let file = URL(fileURLWithPath: "tmp", isDirectory: false)
		let local = LocalURL<IsRelative, IsFolder>.init(url: file)
		XCTAssert(local == nil)
	}
	
	func testJoinAbsoluteWithFolder() {
		let file = URL(fileURLWithPath: "/tmp", isDirectory: true)
		let root = LocalURL<IsAbsolute, IsFolder>.init(url: file)!

		let file2 = URL(fileURLWithPath: "var", isDirectory: true)
		let local = LocalURL<IsRelative, IsFolder>.init(url: file2)!

		let final = join(root, local)
		let result = file.appendingPathComponent(file2.path)
		XCTAssert(final.rawValue.absoluteString == result.absoluteString)
	}

	func testJoinAbsoluteWithFile() {
		let file = URL(fileURLWithPath: "/tmp", isDirectory: true)
		let root = LocalURL<IsAbsolute, IsFolder>.init(url: file)!

		let file2 = URL(fileURLWithPath: "file", isDirectory: false)
		let local = LocalURL<IsRelative, IsFile>.init(url: file2)!

		let final = root <> local
		let result = file.appendingPathComponent(file2.path)
		XCTAssert(final.rawValue.absoluteString == result.absoluteString)
	}

	func testJoinRelativeWithFolder() {
		let file = URL(fileURLWithPath: "tmp", isDirectory: true)
		let root = LocalURL<IsRelative, IsFolder>.init(url: file)!

		let file2 = URL(fileURLWithPath: "var", isDirectory: true)
		let local = LocalURL<IsRelative, IsFolder>.init(url: file2)!

		let final = root <> local
		let result = file.appendingPathComponent(file2.path)
		XCTAssert(final.rawValue.absoluteString == result.absoluteString)
	}
	
	func testJoinRelativeWithFile() {
		let file = URL(fileURLWithPath: "tmp", isDirectory: true)
		let root = LocalURL<IsRelative, IsFolder>.init(url: file)!

		let file2 = URL(fileURLWithPath: "file", isDirectory: false)
		let local = LocalURL<IsRelative, IsFile>.init(url: file2)!

		let final = root <> local
		let result = file.appendingPathComponent(file2.path)
		XCTAssert(final.rawValue.absoluteString == result.absoluteString)
	}
}

