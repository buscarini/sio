//
//  SIO+Effects.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	func onFail(do io: SIO<Void, Never, Void>) -> SIO<R, E, A> {
		return self.flatMapError({ error in
			io.require(R.self)
			.mapError(absurd)
			.flatMap { _ in
				SIO<R, E, A>.rejected(error)
			}
		})
	}
	
	func onSuccess(do io: SIO<Void, Never, Void>) -> SIO<R, E, A> {
		return self.flatMap { a in
			io
			.adapt()
			.require(R.self).map { _ in
				a
			}
		}
	}
}
