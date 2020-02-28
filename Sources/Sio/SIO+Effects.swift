//
//  SIO+Effects.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	@inlinable
	func onFail(do io: SIO<Void, Never, Void>) -> SIO<R, E, A> {
		self.flatMapError({ error in
			io.require(R.self)
			.mapError(absurd)
			.flatMap { _ in
				SIO<R, E, A>.rejected(error)
			}
		})
	}
	
	@inlinable
	func onSuccess(do io: SIO<Void, Never, Void>) -> SIO<R, E, A> {
		self.flatMap { a in
			io
			.adapt()
			.require(R.self).map { _ in
				a
			}
		}
	}
}
