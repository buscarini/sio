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
	
	return liftA2(iof.map(curry), first, second)
	
//	return iof.flatMap { f in
//		return liftA2(SIO<R, E, (A) -> (B) -> C>.of(curry(f)), first, second)
//	}
}

public func ap<R, E, A, B>(_ left: SIO<R, E, (A) -> B>, _ right: SIO<R, E, A>) -> SIO<R, E, B> {
	
	let l = left
	let r = right
	
	return SIO<R, E, B>({ (env, reject: @escaping (E) -> (), resolve: @escaping (B) -> ()) in
	
		let resolved = SyncValue<Never, Bool>()
		let leftVal = SyncValue<E, (A) -> B>()
		let rightVal = SyncValue<E, A>()
		
		let checkContinue = {
			guard resolved.notLoaded else { return }

			if l.cancelled {
				leftVal.result = .cancelled
			}
			
			if r.cancelled {
				rightVal.result = .cancelled
			}
			
			print("\(leftVal.result) \(rightVal.result)")
			
			switch (leftVal.result, rightVal.result) {
			case let (.loaded(.right(ab)), .loaded(.right(a))):
				resolved.result = .loaded(.right(true))
				resolve(ab(a))
			case let (.loaded(.left(e)), .loaded):
				resolved.result = .loaded(.right(false))
				reject(e)
			case let (.loaded, .loaded(.left(e))):
				resolved.result = .loaded(.right(false))
				reject(e)
				
			default:
				return
			}
		}
		
		print("fork l")
		l.fork(env, { error in
			leftVal.result = .loaded(.left(error))
		
			print("left error")
			
			checkContinue()
			
		}, { loadedF in
			leftVal.result = .loaded(.right(loadedF))
			
			print("left loaded")
			
			checkContinue()
		})
	
		print("fork r \(r.implementation)")
		r.fork(env, { error in
			rightVal.result = .loaded(.left(error))
			
			print("right error")
			
			checkContinue()
		}, { loadedVal in
			rightVal.result = .loaded(.right(loadedVal))
			
			print("right loaded")
			
			checkContinue()
		})
		
	}, cancel: {
		l.cancel()
		r.cancel()
	})
}
