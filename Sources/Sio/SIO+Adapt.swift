//
//  SIO+Adapt.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 01/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO where R == Void, E == Never {
	@inlinable
	func adapt<S, F>() -> SIO<S, F, A> {
		self
			.require(S.self)
			.mapError(absurd)
	}
}
