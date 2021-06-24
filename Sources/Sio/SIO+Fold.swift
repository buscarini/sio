//
//  SIO+Fold.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	@inlinable
	func fold<B>(_ f: @escaping (E) -> B, _ g: @escaping (A) -> B) -> SIO<R, Never, B> {
		SIO<R, Never, B>({ env, reject, resolve in
			self.fork(
				env,
				{ error in
					resolve(f(error))
				},
				{ value in
					resolve(g(value))
				}
			)
		}, cancel: self.cancel)
	}
	
	@inlinable
	func foldM<B>(_ f: @escaping (E) -> SIO<R, E, B>, _ g: @escaping (A) -> SIO<R, E, B>) -> SIO<R, E, B> {
		self.biFlatMap(f, g)
	}
}
