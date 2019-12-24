//
//  DateTests.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 13/12/2019.
//

import Foundation
import XCTest

import Sio
import SioEffects

class DateTests: XCTestCase {
	func testDate() {
		let date = Date.init(timeIntervalSince1970: 0)
		let dates = Dates.init(date: .of(date))
		
		dates.date.assert(date)
	}
}
