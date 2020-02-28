//
//  SIO+Contravariant.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension SIO {
	/// pullback or contramap for Contravariant functors
	@inlinable
	public func pullback<S>(_ f: @escaping (S) -> (R)) -> SIO<S, E, A> {
		self.dimap(f, id)
	}
}
