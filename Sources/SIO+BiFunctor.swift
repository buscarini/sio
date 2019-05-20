//
//  SIO+BiFunctor.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension SIO {
	public func bimap<F, B>(_ f: @escaping (E) -> F, _ g: @escaping (A) -> B) -> SIO<R, F, B> {
		return SIO<R, F, B>({ env, reject, resolve in
			return self.fork(
				env,
				{ error in
					reject(f(error))
				},
				{ value in
					resolve(g(value))
				}
			)
		}, cancel: _cancel)
	}
}
