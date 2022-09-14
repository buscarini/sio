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
extension SIO where R == Void, E: Error {
	public var future: AnyPublisher<A, E> {
		var work: Work<Never, Result<A, E>>?
		
		return Future<A, E> { promise in
			work = self
				.result()
				.run(promise)
		}
		.handleEvents(receiveCancel: {
			work?.cancel()
		})
		.eraseToAnyPublisher()
	}
}

#endif
