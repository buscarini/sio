//
//  SIO+BiMonad.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension SIO {
	@inlinable
	public func biFlatMap<F, B>(_ f: @escaping (E) -> SIO<R, F, B>, _ g: @escaping (A) -> SIO<R, F, B>) -> SIO<R, F, B> {
		
		return biFlatMapR({ _, e in f(e) }, { _, a in g(a) })
	}
	
	public func biFlatMapR<F, B>(_ f: @escaping (R, E) -> SIO<R, F, B>, _ g: @escaping (R, A) -> SIO<R, F, B>) -> SIO<R, F, B> {
				
		let result = SIO<R, F, B>({ (env, reject: @escaping (F) -> (), resolve: @escaping (B) -> ()) in
			
			let group = DispatchGroup()
			
			var cont: (() -> SIO<R, F, B>)?
			
			group.enter()
			self._fork(
				env,
				{ error in
					guard !self.cancelled else { return }
					cont = {
						f(env, error) //.fork(env, reject, resolve)
					}
					group.leave()
				},
				{ value in
					guard !self.cancelled else { return }
//					g(env, value)._fork(env, reject, resolve)
					cont = {
						g(env, value) //.fork(env, reject, resolve)
					}
					group.leave()
				})
				
				group.notify(queue: .global(), execute: {
					cont!().fork(env, reject, resolve)
				})
			
		}, cancel: self.cancel)
		
		return result
	}
}
