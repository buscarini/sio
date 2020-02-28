//
//  SIO+Result.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 29/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO where E: Error {
	@inlinable
	static func from(_ result: Result<A, E>) -> SIO<Void, E, A> {
		switch result {
		case let .success(a):
			return SIO<Void, E, A>.of(a)
		case let .failure(e):
			return SIO<Void, E, A>.rejected(e)
		}
	}
	
	@inlinable
	func result() -> SIO<R, Never, Result<A, E>> {
		self
			.map { a in
				Result<A, E>.success(a)
			}
			.flatMapError { e in
				SIO<R, Never, Result<A, E>>.of(Result<A, E>.failure(e))
			}
	}
}
