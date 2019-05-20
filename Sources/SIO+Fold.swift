//
//  SIO+Fold.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	func fold<B>(_ f: @escaping (E) -> B, _ g: @escaping (A) -> B) -> SIO<R, Never, B> {
		return SIO<R, Never, B>({ env, reject, resolve in
			return self.fork(
				env,
				{ error in
					resolve(f(error))
				},
				{ value in
					resolve(g(value))
				}
			)
		}, cancel: _cancel)
	}
}
