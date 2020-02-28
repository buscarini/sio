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
		let copy = self
		copy.queue = queue
		return copy
	}
	
	@inlinable
	func forkOn(_ queue: DispatchQueue) -> SIO<R, E, A> {
		SIO({ (env, reject, resolve) in
			self.fork(
				env,
				{ error in
					queue.async {
						reject(error)
					}
				},
				{ result in
					queue.async {
						resolve(result)
					}
				}
			)
		})
	}
}
