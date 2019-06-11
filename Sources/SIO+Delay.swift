//
//  SIO+Delay.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public func delayed<R, E, A>(_ delay: TimeInterval, _ queue: DispatchQueue = .main) -> (SIO<R, E, A>) -> SIO<R, E, A> {
	return { io in
		SIO({ env, reject, resolve in
			queue.asyncAfter(deadline: .now() + delay) {
				io.fork(env, reject, resolve)
			}
		})
	}
}

extension SIO {
	public func delay(_ time: TimeInterval, _ queue: DispatchQueue = .main) -> SIO<R, E, A> {
		return delayed(time, queue)(self)
	}
}
