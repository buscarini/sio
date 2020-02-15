//
//  SIO+BiMonad.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	func biFlatMap<F, B>(_ io: SIO<R, F, B>) -> SIO<R, F, B> {
		return self.biFlatMap({ _ in io }, { _ in io })
	}
	
	func biFlatMap<F, B>(
		_ f: @escaping (E) -> SIO<R, F, B>,
		_ g: @escaping (A) -> SIO<R, F, B>
	) -> SIO<R, F, B> {
		
		let result: SIO<R, F, B>
		
		switch self.implementation {
			case let .success(val):
				result = g(val)
			case let .fail(e):
				result = f(e)
			case .sync, .async:
				let specific = BiFlatMap(sio: self, err: f, succ: g)
				result = SIO<R, F, B>.init(
					.biFlatMap(specific),
					cancel: self.cancel
				)
			
			case let .biFlatMap(impl):
				result = impl.biFlatMap(f, g)
		}
		
		result.queue = self.queue
		result.delay = self.delay
		return result
	}
}
