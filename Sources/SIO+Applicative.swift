//
//  SIO+Applicative.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public func liftA2<R, E, A, B, C>(_ iof: SIO<R, E, (A) -> (B) -> C>, _ first: SIO<R, E, A>, _ second: SIO<R, E, B>) -> SIO<R, E, C> {
	return ap(ap(iof, first),second)
}

public func ap<R, E, A, B, C>(_ iof: SIO<R, E, (A, B) -> C>, _ first: SIO<R, E, A>, _ second: SIO<R, E, B>) -> SIO<R, E, C> {
	return iof.flatMap { f in
		return liftA2(SIO<R, E, (A) -> (B) -> C>.of(curry(f)), first, second)
	}
}

public func ap<R, E, A, B>(_ left: SIO<R, E, (A) -> B>, _ right: SIO<R, E, A>) -> SIO<R, E, B> {

	let group = DispatchGroup()
	
	let l = left
	let r = right
	
	return SIO<R, E, B>({ (env, reject: @escaping (E) -> (), resolve: @escaping (B) -> ()) in
		
		var f: ((A)->B)?
		var val: A?
		
		var errorL: E?
		var errorR: E?
		
		group.enter()
		l.fork(env, { error in
			errorL = error
			group.leave()
			
		}, { loadedF in
			f = loadedF
			
			group.leave()
		})
		
		group.enter()
		r.fork(env, { error in
			errorR = error
			group.leave()
		}, { loadedVal in
			val = loadedVal
			group.leave()
		})
		
		group.notify(queue: .main) {
			if let error = errorR {
				reject(error)
				return
			}
			
			if let error = errorL {
				reject(error)
				return
			}
			
			guard let f = f, let val = val else {
				return
			}
		
			resolve(f(val))
		}
		
	}, cancel: {
		l.cancel()
		r.cancel()
	})
}
