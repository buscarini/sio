//
//  Codec+Dates.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 23/12/2019.
//

import Foundation
import Sio

public extension Codec where E == Never, A == Date, B == Double {
	static var epochSeconds: Codec<Never, Date, Double> {
		.init(to: { value in
			.right(value.timeIntervalSince1970)
		}, from: { seconds in
			.right(Date.init(timeIntervalSince1970: seconds))
		})
	}
}

public extension Codec where E == Error, A == Date, B == String {
	static func dateFormatter(_ df: DateFormatter) -> Codec<CodecError, Date, String> {
		.init(to: { value in
			.right(df.string(from: value))
		}, from: { string in
			.from(df.date(from: string), .invalid)
		})
	}
}
