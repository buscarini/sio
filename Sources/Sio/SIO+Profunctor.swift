//
//  SIO+Profunctor.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	func dimap<S, B>(
		_ pre: @escaping (S) -> R,
		_ post: @escaping (A) -> B
	) -> SIO<S, E, B> {
		SIO<S, E, B>(
			{ s, reject, resolve in
				self.fork(pre(s), reject, { a in
					resolve(post(a))
				})
			},
			cancel: {
				self.cancel()
			}
		)
	}
}
