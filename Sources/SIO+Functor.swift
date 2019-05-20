//
//  SIO+Functor.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension SIO {
	public func map<B>(_ f: @escaping (A) -> (B)) -> SIO<R, E, B> {
		return self.bimap(id, f)
	}
}
