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
		
		switch self.implementation {
			case let .success(val):
				return g(val)
			case let .fail(e):
				return f(e)
			case .eff:
			
				let specific = BiFlatMap(sio: self, err: f, succ: g)
				return SIO<R, F, B>.init(
					.biFlatMap(specific),
					cancel: self.cancel
				)
			
			case let .biFlatMap(impl):
				return impl.biFlatMap(f, g)
		}
	}
}
