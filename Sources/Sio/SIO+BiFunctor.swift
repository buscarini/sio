//
//  SIO+BiFunctor.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension SIO {
	public func bimap<F, B>(
		_ f: @escaping (E) -> F,
		_ g: @escaping (A) -> B
	) -> SIO<R, F, B> {
		let result: SIO<R, F, B>
		
		switch self.implementation {
			case let .success(val):
				result = .of(g(val))
			case let .fail(e):
				result = .rejected(f(e))
			case let .sync(sync):
				result = .sync { r in
					sync(r)?.bimap(f, g)
				}
			
			case let .async(async):
				result = SIO<R, F, B>.init({ (r, reject, resolve) in
					async(
						r,
						{ e in
							reject(f(e))
						},
						{ a in
							resolve(g(a))
						}
					)
				})
			
			case let .biFlatMap(impl):
				result = impl.bimap(f, g)
		}
		
		result.scheduler = self.scheduler
		result.delay = self.delay
		
		return result
	}
}
