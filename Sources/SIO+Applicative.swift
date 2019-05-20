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
	
	var l = left
	var r = right
	
	return SIO<R, E, B>({ (env, reject: @escaping (E) -> (), resolve: @escaping (B) -> ()) in
		var f: ((A)->B)?
		var val: A?
		
		var rejected = false
		
		let guardReject: (E) -> () = { x in
			if (!rejected) {
				rejected = true;
				reject(x)
			}
		}
		
		let tryResolve = {
			guard let f = f, let val = val else { return }
			resolve(f(val))
		}
		
		l.fork(env, guardReject, { loadedF in
			guard !rejected else {
				return
			}
			
			f = loadedF
			
			tryResolve()
		})
		
		r.fork(env, guardReject, { loadedVal in
			guard !rejected else {
				return
			}
			
			val = loadedVal
			
			tryResolve()
		})
	}, cancel: {
		l.cancel()
		r.cancel()
	})
}
