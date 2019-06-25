//
//  SIO+Flip.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	func flip() -> SIO<R, A, E> {
		return SIO<R, A, E>({ env, reject, resolve in
			return self.fork(
				env,
				resolve,
				reject
			)
		}, cancel: self.cancel)
	}
}
