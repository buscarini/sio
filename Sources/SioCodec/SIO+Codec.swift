//
//  SIO+Codec.swift
//  SioCodec
//
//  Created by José Manuel Sánchez Peñarroja on 03/07/2019.
//

import Foundation
import Sio

public func compose<R, E, A, B>(_ left: SIO<R, E, A>, _ codec: Codec<E, A, B>) -> SIO<R, E, B> {
	return left.flatMap {
		SIO<Void, E, B>.from(codec.to($0)).require(R.self)
	}
}

public func >>> <R, E, A, B>(_ left: SIO<R, E, A>, _ codec: Codec<E, A, B>) -> SIO<R, E, B> {
	return compose(left, codec)
}

public func <<< <R, E, A, B>(_ codec: Codec<E, A, B>, _ store: SIO<R, E, A>) -> SIO<R, E, B> {
	return compose(store, codec)
}

public extension SIO {
	func decode<B>(_ codec: Codec<E, B, A>) -> SIO<R, E, B> {
		self.flatMap {
			SIO<Void, E, B>.from(codec.from($0)).require(R.self)
		}
	}
	
	func encode<B>(_ codec: Codec<E, A, B>) -> SIO<R, E , B> {
		self.flatMap { a in
			SIO<Void, E, B>.from(codec.to(a)).require(R.self)
		}
	}
}
