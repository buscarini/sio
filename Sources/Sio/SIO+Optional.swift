//
//  SIO+Conversions.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	@inlinable
	static func from(_ optional: A?, default value: A) -> SIO {
		SIO.of(optional ?? value)
	}
	
	@inlinable
	static func from(_ optional: A?, _ error: E) -> SIO {
		if let value = optional {
			return SIO.of(value)
		}
		else {
			return SIO.rejected(error)
		}
	}
	
	@inlinable
	func optional() -> SIO<R, Never, A?> {
		self
			.map { .some($0) }
			.flatMapError { _ in
				return SIO<R, Never, A?>.of(nil)
		}
	}
}

public extension SIO where E == Void {
	@inlinable
	static func from(_ f: @escaping (R) -> A?) -> SIO<R, Void, A> {
		SIO.sync { env in
			Either.from(f(env), ())
		}
	}
}
