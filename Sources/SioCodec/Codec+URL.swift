//
//  Codec+URL.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 17/06/2020.
//

import Foundation
import Sio

public extension Codec where E == Void, A == URL, B == String {
	static var url: Codec<E, A, B> {
		.init(to: { value in
			.right(value.absoluteString)
		}, from: { string in
			Either.from(URL(string: string), ())
		})
	}
}
