//
//  SIO+BiMonad.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	@inlinable
	func biFlatMap<F, B>(
		_ io: SIO<R, F, B>
	) -> SIO<R, F, B> {
		self.biFlatMap({ _ in io }, { _ in io })
	}
	
	@inlinable
	func biFlatMap<F, B>(
		_ f: @escaping (E) -> SIO<R, F, B>,
		_ g: @escaping (A) -> SIO<R, F, B>
	) -> SIO<R, F, B> {
		SIO<R, F, B>(
			work: { r, reject, resolve in
				Work<F, B>(
					{
						_ = self.work(
							r,
							{ e in
								f(e).fork(r, reject, resolve)
							},
							{ a in
								g(a).fork(r, reject, resolve)
							}
						)
					},
					cancel: self.onCancel
				)
				
//				self.work(
//					r,
//					{ e in
//						f(e).fork(r, reject, resolve)
//					},
//					{ a in
//						g(a).fork(r, reject, resolve)
//					}
//				)
			}
		)
		
		
		
//		let result: SIO<R, F, B>
//
//		switch self.implementation {
//			case let .success(val):
//				result = g(val)
//			case let .fail(e):
//				result = f(e)
//			case .sync, .async:
//				let specific = BiFlatMap(sio: self, err: f, succ: g)
//				result = SIO<R, F, B>.init(
//					.biFlatMap(specific),
//					cancel: self.cancel
//				)
//				result.scheduler = self.scheduler
//				result.delay = self.delay
//
//			case let .biFlatMap(impl):
//				result = impl.biFlatMap(f, g)
//		}
//
//		return result
	}
}

public extension SIO {
	@inlinable
	func when(
		_ f: @escaping (A) -> Bool,
		run: @escaping (A) -> SIO<R, E, A>) -> SIO<R, E, A> {
		self.flatMap { value in
			guard f(value) else {
				return .of(value)
			}
			
			return run(value)
		}
	}
	
	@inlinable
	func `guard`<B>(
		_ f: @escaping (A) -> Bool,
		else left: @escaping (A) -> SIO<R, E, B>,
		run right: @escaping (A) -> SIO<R, E, B>
	) -> SIO<R, E, B> {
		self.flatMap { t in
			f(t) ? right(t) : left(t)
		}
	}
}
