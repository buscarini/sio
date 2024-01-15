//
//  SIO+Combine.swift
//  SioCodecTests
//
//  Created by José Manuel Sánchez Peñarroja on 30/05/2020.
//

import Foundation

#if canImport(Combine)
import Combine

@available(iOS 13.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0, *)
extension SIO where R == Void, E: Error {
	public var future: AnyPublisher<A, E> {
		Future<A, E> { promise in
			self
				.result()
				.run(promise)
		}
		.handleEvents(receiveCancel: {
			self.cancel()
		})
		.eraseToAnyPublisher()
	}
}

#endif
