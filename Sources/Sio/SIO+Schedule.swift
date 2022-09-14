//
//  SIO+Schedule.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	@inlinable
	func scheduleOn(_ queue: DispatchQueue) -> SIO<R, E, A> {
		scheduleOn(QueueScheduler(queue: queue))
	}
	
	@inlinable
	func scheduleOn(_ scheduler: Scheduler) -> SIO<R, E, A> {
		var copy = self
		copy.scheduler = AnyScheduler(scheduler)
		return copy
	}
	
	@inlinable
	func forkOn(_ queue: DispatchQueue) -> SIO<R, E, A> {
		forkOn(QueueScheduler(queue: queue))
	}
	
	@inlinable
	func forkOn(_ scheduler: Scheduler) -> SIO<R, E, A> {
		SIO({ (env, reject, resolve) in
			self.fork(
				env,
				{ error in
					scheduler.run {
						reject(error)
					}
				},
				{ result in
					scheduler.run {
						resolve(result)
					}
				}
			)
		})
	}
}
