//
//  SIO+Events.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 27/06/2019.
//

import Foundation

public extension SIO {
	func onCompletion(_ task: SIO<Void, Never, Void>) -> SIO<R, E, A> {
		return self.biFlatMap({ e in
			task
				.adapt()
				.flatMap { _ in
					.rejected(e)
				}
			
		}, { a in
			task
				.adapt()
				.const(a)
		})
	}
}
