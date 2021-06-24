//
//  CurryTests.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 05/12/2019.
//

import Foundation

import XCTest
import Sio

class CurryTests: XCTestCase {
	func testCurry1() {
		func add(_ a: Int) -> Int {
			a
		}
		
		XCTAssert(curry(add)(1) == 1)
	}
	
	func testCurry2() {
		func add(_ left: Int, _ right: Int) -> Int {
			left + right
		}
		
		XCTAssert(curry(add)(1)(2) == 3)
	}
	
	func testCurry3() {
		func add(_ a: Int, _ b: Int, _ c: Int) -> Int {
			a + b + c
		}
		
		XCTAssert(curry(add)(1)(1)(1) == 3)
	}
	
	func testCurry4() {
		func add(_ a: Int, _ b: Int, _ c: Int, _ d: Int) -> Int {
			a + b + c + d
		}
		
		XCTAssert(curry(add)(1)(1)(1)(1) == 4)
	}
	
	func testCurry5() {
		func add(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int) -> Int {
			a + b + c + d + e
		}
		
		XCTAssert(curry(add)(1)(1)(1)(1)(1) == 5)
	}
	
	func testCurry6() {
		func add(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int, _ f: Int) -> Int {
			a + b + c + d + e + f
		}
		
		XCTAssert(curry(add)(1)(1)(1)(1)(1)(1) == 6)
	}
	
	func testCurry7() {
		func add(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int, _ f: Int, _ g: Int) -> Int {
			a + b + c + d + e + f + g
		}
		
		XCTAssert(curry(add)(1)(1)(1)(1)(1)(1)(1) == 7)
	}
	
	func testCurry8() {
		func add(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int, _ f: Int, _ g: Int, _ h: Int) -> Int {
			a + b + c + d + e + f + g + h
		}
		
		XCTAssert(curry(add)(1)(1)(1)(1)(1)(1)(1)(1) == 8)
	}
	
	func testCurry9() {
		func add(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int, _ f: Int, _ g: Int, _ h: Int, _ i: Int) -> Int {
			a + b + c + d + e + f + g + h + i
		}
		
		XCTAssert(curry(add)(1)(1)(1)(1)(1)(1)(1)(1)(1) == 9)
	}
	
	func testCurry10() {
		func add(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int, _ f: Int, _ g: Int, _ h: Int, _ i: Int, _ j: Int) -> Int {
			a + b + c + d + e + f + g + h + i + j
		}
		
		XCTAssert(curry(add)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1) == 10)
	}
	
	func testCurry11() {
		func add(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int, _ f: Int, _ g: Int, _ h: Int, _ i: Int, _ j: Int, _ k: Int) -> Int {
			a + b + c + d + e + f + g + h + i + j + k
		}
		
		XCTAssert(curry(add)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1) == 11)
	}
	
	func testCurry12() {
		func add(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int, _ f: Int, _ g: Int, _ h: Int, _ i: Int, _ j: Int, _ k: Int, _ l: Int) -> Int {
			a + b + c + d + e + f + g + h + i + j + k + l
		}
		
		XCTAssert(curry(add)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1) == 12)
	}
	
	func testCurry13() {
		func add(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int, _ f: Int, _ g: Int, _ h: Int, _ i: Int, _ j: Int, _ k: Int, _ l: Int, _ m: Int) -> Int {
			a + b + c + d + e + f + g + h + i + j + k + l + m
		}
		
		XCTAssert(curry(add)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1) == 13)
	}
	
	func testCurry14() {
		func add(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int, _ f: Int, _ g: Int, _ h: Int, _ i: Int, _ j: Int, _ k: Int, _ l: Int, _ m: Int, _ n: Int) -> Int {
			a + b + c + d + e + f + g + h + i + j + k + l + m + n
		}
		
		XCTAssert(curry(add)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1) == 14)
	}
	
	func testCurry15() {
		func add(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int, _ f: Int, _ g: Int, _ h: Int, _ i: Int, _ j: Int, _ k: Int, _ l: Int, _ m: Int, _ n: Int, o: Int) -> Int {
			a + b + c + d + e + f + g + h + i + j + k + l + m + n + o
		}
		
		XCTAssert(curry(add)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1) == 15)
	}
	
	func testCurry16() {
		func add(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int, _ f: Int, _ g: Int, _ h: Int, _ i: Int, _ j: Int, _ k: Int, _ l: Int, _ m: Int, _ n: Int, o: Int, _ p: Int) -> Int {
			a + b + c + d + e + f + g + h + i + j + k + l + m + n + o + p
		}
		
		XCTAssert(curry(add)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1) == 16)
	}
	
	func testCurry17() {
		func add(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int, _ f: Int, _ g: Int, _ h: Int, _ i: Int, _ j: Int, _ k: Int, _ l: Int, _ m: Int, _ n: Int, o: Int, _ p: Int, _ q: Int) -> Int {
			a + b + c + d + e + f + g + h + i + j + k + l + m + n + o + p + q
		}
		
		XCTAssert(curry(add)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1) == 17)
	}
	
	func testCurry18() {
		func add(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int, _ f: Int, _ g: Int, _ h: Int, _ i: Int, _ j: Int, _ k: Int, _ l: Int, _ m: Int, _ n: Int, o: Int, _ p: Int, _ q: Int, _ r: Int) -> Int {
			a + b + c + d + e + f + g + h + i + j + k + l + m + n + o + p + q + r
		}
		
		XCTAssert(curry(add)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1) == 18)
	}
	
	func testCurry19() {
		func add(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int, _ f: Int, _ g: Int, _ h: Int, _ i: Int, _ j: Int, _ k: Int, _ l: Int, _ m: Int, _ n: Int, o: Int, _ p: Int, _ q: Int, _ r: Int, _ s: Int) -> Int {
			a + b + c + d + e + f + g + h + i + j + k + l + m + n + o + p + q + r + s
		}
		
		XCTAssert(curry(add)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1) == 19)
	}
	
	func testCurry20() {
		func add(_ a: Int, _ b: Int, _ c: Int, _ d: Int, _ e: Int, _ f: Int, _ g: Int, _ h: Int, _ i: Int, _ j: Int, _ k: Int, _ l: Int, _ m: Int, _ n: Int, o: Int, _ p: Int, _ q: Int, _ r: Int, _ s: Int, _ t: Int) -> Int {
			a + b + c + d + e + f + g + h + i + j + k + l + m + n + o + p + q + r + s + t
		}
		
		XCTAssert(curry(add)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1)(1) == 20)
	}
}
