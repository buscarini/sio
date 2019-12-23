//
//  Codec+Dates.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 23/12/2019.
//

import Foundation
import Sio

public extension Codec where E == Error, A == Date, B == Double {
	static var epochSeconds: Codec<Error, Date, Double> {
		.init(to: { value in
			.right(value.timeIntervalSince1970)
		}, from: { seconds in
			.right(Date.init(timeIntervalSince1970: seconds))
		})
	}
}
