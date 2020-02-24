//
//  SIO+BiFunctor.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension SIO {
	@inlinable
	public func bimap<F, B>(
		_ f: @escaping (E) -> F,
		_ g: @escaping (A) -> B
	) -> SIO<R, F, B> {
		biFlatMap({ e in
			SIO<R, F, B>.rejected(f(e))
		}, { a in
			SIO<R, F, B>.of(g(a))
		})
	}
}
