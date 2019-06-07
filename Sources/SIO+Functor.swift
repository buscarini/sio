//
//  SIO+Functor.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

extension SIO {
	@inlinable
	public func map<B>(_ f: @escaping (A) -> (B)) -> SIO<R, E, B> {
		return self.bimap(id, f)
	}
	
//	@inlinable
//	public func mapR<B>(_ f: @escaping (R, A) -> (B)) -> SIO<R, E, B> {
//		return self.bimapR({ _, e in e }, f)
//	}
	
	@inlinable
	public func map2<Element, B>(_ f: @escaping (Element) -> (B)) -> SIO<R, E, [B]> where A == [Element] {
		return self.bimap(id, { $0.map(f) })
	}
	
	@inlinable
	public func map2<Element, B>(_ f: @escaping (Element) -> (B)) -> SIO<R, E, B?> where A == Element? {
		return self.bimap(id, { $0.map(f) })
	}
	
	@inlinable
	public var void: SIO<R, E, Void> {
		return self.map { _ in () }
	}
}
