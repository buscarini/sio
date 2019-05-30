//
//  SIO+Utils.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	func provideSome<R0>(_ f: @escaping (R0) -> R) -> SIO<R0, E, A> {
		return SIO<R0, E, A>({ r, reject, resolve in
			self.fork(f(r), reject, resolve)
		})
	}
	
	func provide(_ req: R) -> SIO<Void, E, A> {
		return self.provideSome { _ in
			return req
		}
	}
}

public extension SIO where R == Void {
	func require<R>(_ type: R.Type) -> SIO<R, E, A> {
		return self.pullback(discard)
	}
}
