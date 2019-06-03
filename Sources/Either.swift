//
//  Either.swift
//  sio-iOS Tests
//
//  Created by José Manuel Sánchez Peñarroja on 02/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public enum Either<E, A> {
	case left(E)
	case right(A)
}
