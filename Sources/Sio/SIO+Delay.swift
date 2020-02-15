//
//  SIO+Delay.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public func delayed<R, E, A>(_ delay: TimeInterval, _ queue: DispatchQueue = .global()) -> (SIO<R, E, A>) -> SIO<R, E, A> {
	return { io in
		// FIXME: Change this to setting the queue
		let res = SIO({ env, reject, resolve in
			queue.asyncAfter(deadline: .now() + delay) {
				io.fork(env, reject, resolve)
			}
		}, cancel: io.cancel)
//		res.queue = queue
//		res.delay = delay
		
		return res
	}
}

public extension SIO {
	func delay(_ time: TimeInterval, _ queue: DispatchQueue = .global()) -> SIO<R, E, A> {
		delayed(time, queue)(self)
	}
	
	func sleep(_ time: TimeInterval) -> SIO<R, E, A> {
		self.flatMap { value in
			SIO<R, E, A>.of(value).delay(time)
		}
	}
}
