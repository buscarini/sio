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
		return self.bimapR({ _, e in f(e) }, { _, a in g(a) })
	}
	
	public func bimapR<F, B>(
		_ f: @escaping (R, E) -> F,
		_ g: @escaping (R, A) -> B
	) -> SIO<R, F, B> {
		return biFlatMap({ e in
			SIO<R, F, B>.environment()
				.flatMap { r in
					.rejected(f(r, e))
				}
			
		}, { a in
			SIO<R, F, B>.environment()
				.map { r in
					g(r, a)
			}
		})
		
//		return SIO<R, F, B>({ env, reject, resolve in
//			return self.fork(
//				env,
//				{ error in
//					reject(f(env, error))
//			},
//				{ value in
//					resolve(g(env, value))
//			}
//			)
//		}, cancel: self.cancel)
	}
}
