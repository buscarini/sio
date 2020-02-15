//
//  SIO+Alternative.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public func or<R, E, A>(_ first: SIO<R, E, A>, _ second: SIO<R, E, A>) -> SIO<R, E, A> {
	SIO<R, E, A>(
		{ (env, reject, resolve) in
		first.fork(
			env,
			{ _ in
				second.fork(env, reject, resolve)
			}, resolve
		)
		},
		cancel: {
			first.cancel()
			second.cancel()
		}
	)
}

public func <|><R, E, A>(first: SIO<R, E, A>, second: SIO<R, E, A>) -> SIO<R, E, A> {
	or(first, second)
}

public func firstSuccess<R, E, A>(_ first: SIO<R, E, A>, _ rest: [SIO<R, E, A>]) -> SIO<R, E, A> {
	rest.reduce(first, { acc, item in
		acc <|> item
	})
}
