//
//  SIO+RunAt.swift
//  SioValueStoreTests
//
//  Created by José Manuel Sánchez Peñarroja on 21/12/2019.
//

import Foundation

public extension SIO {
	@inlinable
	func runAt(_ date: Date) -> SIO<R, E, A> {
		self |> delayed(date.timeIntervalSinceNow)
	}
}
