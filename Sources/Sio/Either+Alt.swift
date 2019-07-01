//
//  Either+Alt.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension Either {
	public static func <|> (_ left: Either<A, B>, _ right: @autoclosure () -> Either<A, B>) -> Either<A, B> {
		return left.isRight ? left : right()
	}
	
	public static func <|> (_ left: Either<A, B>, _ defaultValue: B) -> B {
		return left.right ?? defaultValue
	}
}
