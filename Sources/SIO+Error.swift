//
//  SIO+Error.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	func mapError<F>(_ f: @escaping (E) -> (F)) -> SIO<R, F, A> {
		return self.bimap(f, id)
	}
	
	func flatMapError<F>(_ f: @escaping (E) -> (SIO<R, F, A>)) -> SIO<R, F, A> {
		return self.biFlatMap(f, { SIO<R, F, A>.of($0) })
	}
}

public extension SIO where E == Error {
	init(catching: @escaping (R) throws -> A) {
		self.init({ (env, reject, resolve) in
			do {
				resolve(try catching(env))
			}
			catch let error {
				reject(error)
			}
		})
	}
}
