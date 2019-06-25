//
//  SIO+Date.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 21/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import Sio

public struct Dates {
	public var date = defaultDate
	
	public init(
		date: UIO<Date>
	) {
		self.date = date
	}
	
	static var defaultDate: UIO<Date> {
		return UIO<Date>({ _, reject, resolve in
			resolve(Date())
		})
	}
}
