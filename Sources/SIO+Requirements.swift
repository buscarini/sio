//
//  SIO+Utils.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	func provide(_ req: R) -> SIO<Void, E, A> {
		return SIO<Void, E, A>({ _, reject, resolve in
			self.fork(req, reject, resolve)
		})
	}
}

public extension SIO where R == Void {
	func require<R>(_ type: R.Type) -> SIO<R, E, A> {
		return SIO<R, E, A>({ _, reject, resolve in
			self.fork((), reject, resolve)
		})
	}
}
