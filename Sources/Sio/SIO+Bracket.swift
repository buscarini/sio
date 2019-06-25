//
//  SIO+Bracket.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 29/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	func bracket<B>(
		_ release: @escaping (A) -> SIO<R, Never, Void>,
		_ use: @escaping (A) -> SIO<R, E, B>) -> SIO<R, E, B> {
		return SIO.bracket(self, release, use)
	}
	
	static func bracket<B>(
		_ acquire: SIO<R, E, A>,
		_ release: @escaping (A) -> SIO<R, Never, Void>,
		_ use: @escaping (A) -> SIO<R, E, B>) -> SIO<R, E, B> {
		
		return acquire
			.flatMap { a in
				use(a)
				.flatMap { b in
					release(a)
						.const(b)
						.mapError(absurd)
				}
			}
	}
}
