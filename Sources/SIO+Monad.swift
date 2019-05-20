//
//  SIO+Monad.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension SIO {
	public func flatMap<B>(_ f: @escaping (A) -> (SIO<R, E, B>)) -> SIO<R, E, B> {
		return self.biFlatMap({ SIO<R, E, B>.rejected($0) }, f)
	}
	
	public func replicateM(_ count: Int) -> SIO<R, E, [A]> {
		return Array(1...count).traverse { _ in
			self
		}
	}
}
