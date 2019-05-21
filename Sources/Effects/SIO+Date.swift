//
//  SIO+Date.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 21/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	static var date: UIO<Date> {
		return UIO<Date>({ _, reject, resolve in
			resolve(Date())
		})
	}
}
