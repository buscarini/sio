//
//  SIO+Conversions.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	static func from(_ optional: A?, default value: A) -> SIO {
		if let value = optional {
			return SIO.of(value)
		}
		else {
			return SIO.of(value)
		}
	}
	
	static func from(_ optional: A?, _ error: E) -> SIO {
		if let value = optional {
			return SIO.of(value)
		}
		else {
			return SIO.rejected(error)
		}
	}
	
	func optional() -> SIO<R, Never, A?> {
		return self
			.map { .some($0) }
			.flatMapError { _ in
				return SIO<R, Never, A?>.of(nil)
		}
	}
}

public extension SIO where E == Void {
	static func from(_ f: @escaping (R) -> A?) -> SIO<R, Void, A> {
		return SIO { env, reject, resolve in
			guard let value = f(env) else {
				reject(())
				return
			}
			
			resolve(value)
		}
	}
}
