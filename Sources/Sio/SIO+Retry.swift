//
//  SIO+Retry.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

//public extension SIO {
//	@inlinable
//	func retry(_ times: Int) -> SIO<R, E, A> {
//		retry(times: times, modify: id)
//	}
//	
//	@inlinable
//	func retry(
//		times: Int,
//		modify: @escaping (SIO<R, E, A>) -> SIO<R, E, A>
//	) -> SIO<R, E, A> {
//		guard times > 0 else {
//			return self
//		}
//		
//		return self <|> modify(self.retry(times: times - 1, modify: modify))
//	}
//	
//	@inlinable
//	func retry(
//		times: Int,
//		delay: Seconds<TimeInterval>,
//		scheduler: Scheduler
//	) -> SIO<R, E, A> {
//		self.retry(times: times, modify: { io in
//			io.delay(delay, scheduler)
//		})
//	}
//}
