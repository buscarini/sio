//
//  SIO+Bracket.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 29/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	func bracket<S, B>(_ pre: SIO<S, E, R>, _ post: SIO<A, E, B>) -> SIO<S, E, B> {
		return pre
			.flatMap { env in
				self.provide(env).require(S.self)
			}
			.flatMap { a in
				post.provide(a).require(S.self)
			}
	}
}
