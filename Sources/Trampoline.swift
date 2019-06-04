//
//  Trampoline.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 04/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

enum Trampoline<A, E>{
	case success(A)
	case fail(E)
	case nextFail(() -> Trampoline<A, E>)
	case nextSuccess(() -> Trampoline<A, E>)
}
