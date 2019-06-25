//
//  Either+Alt.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension Either {
	public static func <|> (_ left: Either<T, U>, _ right: @autoclosure () -> Either<T, U>) -> Either<T, U> {
		return left.isRight ? left : right()
	}
	
	public static func <|> (_ left: Either<T, U>, _ defaultValue: U) -> U {
		return left.right ?? defaultValue
	}
}
