//
//  SIO+Timeout.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 23/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	func timeout(_ timeout: TimeInterval) -> SIO<R, E, A?> {
		return race(
			SIO<R, E, A?>.of(nil).delay(timeout, DispatchQueue.main),
			self.map(A?.some)
		)
	}
	
	func timeoutTo(_ value: A, _ timeout: TimeInterval) -> SIO<R, E, A> {
		return race(self, SIO<R, E, A>.of(value).delay(timeout, DispatchQueue.main))
	}
}
