//
//  SIO+Applicative.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

@inlinable
public func liftA2<R, E, A, B, C>(_ iof: SIO<R, E, (A) -> (B) -> C>, _ first: SIO<R, E, A>, _ second: SIO<R, E, B>) -> SIO<R, E, C> {
	return ap(ap(iof, first), second)
}

@inlinable
public func ap<R, E, A, B, C>(_ iof: SIO<R, E, (A, B) -> C>, _ first: SIO<R, E, A>, _ second: SIO<R, E, B>) -> SIO<R, E, C> {
	return iof.flatMap { f in
		return liftA2(SIO<R, E, (A) -> (B) -> C>.of(curry(f)), first, second)
	}
}

public func ap<R, E, A, B>(_ left: SIO<R, E, (A) -> B>, _ right: SIO<R, E, A>) -> SIO<R, E, B> {
	
	let l = left
	let r = right
	
	return SIO<R, E, B>({ (env, reject: @escaping (E) -> (), resolve: @escaping (B) -> ()) in
	
		let leftVal = SyncValue<E, (A) -> B>()
		let rightVal = SyncValue<E, A>()
		
		let checkContinue = {
			if l.cancelled {
				leftVal.result = .cancelled
			}
			
			if r.cancelled {
				rightVal.result = .cancelled
			}
			
//			print("\(leftVal.result) \(rightVal.result)")
			
			switch (leftVal.result, rightVal.result) {
			case let (.loaded(.right(ab)), .loaded(.right(a))):
				resolve(ab(a))
			case let (.loaded(.left(e)), .loaded):
				reject(e)
			case let (.loaded, .loaded(.left(e))):
				reject(e)
				
			default:
				return
			}
		}

		l.fork(env, { error in
			leftVal.result = .loaded(.left(error))
			
			checkContinue()

		}, { loadedF in
			leftVal.result = .loaded(.right(loadedF))
			
			checkContinue()
		})

		r.fork(env, { error in
			rightVal.result = .loaded(.left(error))
			
			checkContinue()
		}, { loadedVal in
			rightVal.result = .loaded(.right(loadedVal))
			
			checkContinue()
		})
	}, cancel: {
		l.cancel()
		r.cancel()
	})
}
