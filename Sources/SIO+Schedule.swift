//
//  SIO+Schedule.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	func scheduleOn(_ queue: DispatchQueue) -> SIO<R, E, A> {
//		self.queue = queue
//		return self
		
//		let copy = self
//		copy.queue = queue
//		return copy
		
		return SIO({ (env, reject, resolve) in
			queue.async {
				self.fork(env, reject, resolve)
			}
		}, cancel: self.cancel)
	}
	
	func forkOn(_ queue: DispatchQueue) -> SIO<R, E, A> {
		return SIO({ (env, reject, resolve) in
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
