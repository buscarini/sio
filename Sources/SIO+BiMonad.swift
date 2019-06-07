//
//  SIO+BiMonad.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension SIO {
	public func biFlatMap<F, B>(_ f: @escaping (E) -> SIO<R, F, B>, _ g: @escaping (A) -> SIO<R, F, B>) -> SIO<R, F, B> {
		
		let specific = BiFlatMap(sio: self, err: f, succ: g)
		
		return SIO<R, F, B>.init(
			.biFlatMap(specific),
			cancel: self.cancel
		)
			
		
		
		
//		switch self.trampoline {
//		case let .success(val):
//			return g(val)
//		case let .fail(e):
//			return f(e)
//		case .eff:
//			return SIO<R, F, B>({ env, reject, resolve in
//				guard let result = self.forkSync(env) else {
//					// Cancelled
//					return
//				}
//
//				switch result {
//				case let .left(e):
//					f(e).fork(env, reject, resolve)
//				case let .right(a):
//					g(a).fork(env, reject, resolve)
//				}
//			})
//		case let .biFlatMap(impl):
//			return SIO<R, F, B>({ env, reject, resolve in
//				guard let result = impl.forkSync(env) else {
//					// Cancelled
//					return
//				}
//
//				switch result {
//				case let .left(e):
//					f(e).fork(env, reject, resolve)
//				case let .right(a):
//					g(a).fork(env, reject, resolve)
//				}
//			})
		
//			let result = SIO<R, F, B>({ (env, reject: @escaping (F) -> (), resolve: @escaping (B) -> ()) in
//
//				let group = DispatchGroup()
//
//				var cont: (() -> SIO<R, F, B>)?
//
//				group.enter()
//				computation(
//					env,
//					{ error in
//						cont = {
//							f(error)
//						}
//						group.leave()
//				},
//					{ value in
//						cont = {
//							g(value)
//						}
//						group.leave()
//				})
//
//				group.notify(queue: .global(), execute: {
//					cont!().fork(env, reject, resolve)
//				})
//
//			}, cancel: self.cancel)
//			return result
//		}
		
//		return biFlatMapR({ _, e in f(e) }, { _, a in g(a) })
	}
	
//	public func biFlatMapR<F, B>(_ f: @escaping (R, E) -> SIO<R, F, B>, _ g: @escaping (R, A) -> SIO<R, F, B>) -> SIO<R, F, B> {
//
//		switch self.trampoline {
//		case let .success(val)?:
//			return f(val)
//		case let .fail(e)?:
//			return g(e)
//		case let .eff(computation)?:
//			return
//		}
//
//
//		let result = SIO<R, F, B>({ (env, reject: @escaping (F) -> (), resolve: @escaping (B) -> ()) in
//
//			let group = DispatchGroup()
//
//			var cont: (() -> SIO<R, F, B>)?
//
//			group.enter()
//			self.fork(
//				env,
//				{ error in
//					cont = {
//						f(env, error) //.fork(env, reject, resolve)
//					}
//					group.leave()
//				},
//				{ value in
////					g(env, value)._fork(env, reject, resolve)
//					cont = {
//						g(env, value) //.fork(env, reject, resolve)
//					}
//					group.leave()
//				})
//
//				group.notify(queue: .global(), execute: {
//					cont!().fork(env, reject, resolve)
//				})
//
//		}, cancel: self.cancel)
//
//		return result
//	}
}
