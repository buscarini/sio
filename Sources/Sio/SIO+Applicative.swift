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
	ap(ap(iof, first), second)
}

@inlinable
public func ap<R, E, A, B, C>(_ iof: SIO<R, E, (A, B) -> C>, _ first: SIO<R, E, A>, _ second: SIO<R, E, B>) -> SIO<R, E, C> {
	liftA2(iof.map(curry), first, second)
}

let apQueue = DispatchQueue.init(label: "ap")

public func ap<R, E, A, B>(_ left: SIO<R, E, (A) -> B>, _ right: SIO<R, E, A>) -> SIO<R, E, B> {
	
	let l = left
	let r = right
	
	var cancelled = false
	
	return SIO<R, E, B>({ (env, reject: @escaping (E) -> (), resolve: @escaping (B) -> ()) in
	
		let resolved = SyncValue<Never, Bool>()
		let leftVal = SyncValue<E, (A) -> B>()
		let rightVal = SyncValue<E, A>()
		
		let checkContinue = {
			apQueue.async {
				guard resolved.notLoaded, cancelled == false, l.cancelled == false, r.cancelled == false else { return }
				
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
		cancelled = true
		l.cancel()
		r.cancel()
	})
}
