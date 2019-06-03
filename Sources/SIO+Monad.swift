//
//  SIO+Monad.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension SIO {
	@inlinable
	public func flatMap<B>(_ f: @escaping (A) -> (SIO<R, E, B>)) -> SIO<R, E, B> {
		return self.flatMapR({ _, a in f(a) })
	}
	
	@inlinable
	public func flatMapR<B>(_ f: @escaping (R, A) -> (SIO<R, E, B>)) -> SIO<R, E, B> {
		return self.biFlatMapR({ _, e in SIO<R, E, B>.rejected(e) }, f)
	}
	
	@inlinable
	public func replicateM(_ count: Int) -> SIO<R, E, [A]> {
		return Array(1...count).traverse { _ in
			self
		}
	}
}
