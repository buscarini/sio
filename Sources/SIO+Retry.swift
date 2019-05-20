//
//  SIO+Retry.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public func retry<R, E, A>(_ times: Int) -> (SIO<R, E, A>) -> SIO<R, E, A> {
	return { io in
		guard times > 0 else {
			return io
		}
		
		return io <|> retry(times - 1)(io)
	}
}

public func retry<R, E, A>(times: Int, modify: @escaping (SIO<R, E, A>) -> SIO<R, E, A>) -> (SIO<R, E, A>) -> SIO<R, E, A> {
	return { io in
		guard times > 0 else {
			return io
		}
		
		return io <|> retry(times: times - 1, modify: modify)(modify(io))
	}
}

public func retry<R, E, A>(times: Int, delay: TimeInterval) -> (SIO<R, E, A>) -> SIO<R, E, A> {
	return { io in
		return retry(times: times, modify: { io in
			io.delay(delay)
		})(io)
	}
}

