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

	func testInitRelativeFile() {
		let file = URL(fileURLWithPath: "file", isDirectory: false)
		let local = LocalURL<IsRelative, IsFile>.init(url: file)
		XCTAssert(local != nil)
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
	
	func testInitRelativeFolder() {
		let file = URL(fileURLWithPath: "tmp", isDirectory: true)
		let local = LocalURL<IsRelative, IsFolder>.init(url: file)
		XCTAssert(local != nil)
	}

}
