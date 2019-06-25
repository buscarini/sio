//
//  SIO+Creation.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	static func of(_ value: A) -> SIO {
		return SIO(.success(value), cancel: nil)
	}
	
	static func lazy(_ value: @autoclosure @escaping () -> A) -> SIO {
		return SIO({ (_, _, resolve) in
			return resolve(value())
		})
	}

	static func rejected(_ error: E) -> SIO {
		return SIO(.fail(error), cancel: nil)
	}
	
	static func rejectedLazy(_ error: @autoclosure @escaping () -> E) -> SIO {
		return SIO({ (_, reject, _) in
			return reject(error())
		})
	}
	
	static func fromFunc(_ f: @escaping (R) -> A) -> SIO<R, Never, A> {
		return environment().map(f)
	}
}
