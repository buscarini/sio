import Foundation
import Combine
import XCTest

import CombineSchedulers

import Sio
import SioEffects

class DateTests: XCTestCase {
	func testDate() {
		let scheduler = DispatchQueue.test

		let date = Date.init(timeIntervalSince1970: 0)
		let dates = Dates.init(date: .of(date))
		
		dates.date.assert(date, scheduler: scheduler)
	}
}
