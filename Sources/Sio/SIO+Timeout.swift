//
//  SIO+Timeout.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 23/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	@inlinable
	func timeout(
		_ timeout: Seconds<TimeInterval>,
		_ scheduler: AnyScheduler = AnyScheduler(QueueScheduler(queue: .global()))
	) -> SIO<R, E, A?> {
		race(
			self.map(A?.some),
			SIO<R, E, A?>.of(nil).delay(timeout, scheduler)
		)
	}
	
	@inlinable
	func timeoutTo(
		_ value: A,
		_ timeout: Seconds<TimeInterval>,
		_ scheduler: AnyScheduler = AnyScheduler(QueueScheduler(queue: .global()))
	) -> SIO<R, E, A> {
		race(
			self,
			SIO<R, E, A>.of(value).delay(timeout, scheduler)
		)
	}
}
