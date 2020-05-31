//
//  SIO+Delay.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

@inlinable
public func delayed<R, E, A>(
	_ delay: Seconds<TimeInterval>,
	_ scheduler: Scheduler = QueueScheduler(queue: .global())
) -> (SIO<R, E, A>) -> SIO<R, E, A> {
	{ io in
		// FIXME: Change this to setting the queue
		let res = SIO({ env, reject, resolve in
			scheduler.runAfter(after: delay) {
				io.fork(env, reject, resolve)
			}
		}, cancel: io.cancel)
//		res.queue = queue
//		res.delay = delay
		
		return res
	}
}

public extension SIO {
	@inlinable
	func delay(
		_ time: Seconds<TimeInterval>,
		_ scheduler: Scheduler = QueueScheduler(queue: .main)
	) -> SIO<R, E, A> {
		delayed(time, scheduler)(self)
	}
	
	@inlinable
	func sleep(_ time: Seconds<TimeInterval>) -> SIO<R, E, A> {
		self.flatMap { value in
			SIO<R, E, A>.of(value).delay(time)
		}
	}
}
