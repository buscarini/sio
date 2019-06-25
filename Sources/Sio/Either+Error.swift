//
//  Eihter+Error.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension Either where T == Error {
	public static func `try`(_ f: () throws -> U) -> Either<T, U> {
		do {
			return try .right(f())
		}
		catch let error {
			return .left(error)
		}
	}
}
