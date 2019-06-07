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
	
	var localCancelled = false
	
	return SIO<R, E, B>({ (env, reject: @escaping (E) -> (), resolve: @escaping (B) -> ()) in
		
		guard
			let left = l.forkSync(env)?.run(env),
			let right = r.forkSync(env)?.run(env)
		else {
			return
		}
		
		switch (left, right) {
		case let (.left(err), _):
			reject(err)
		case let (_, .left(err)):
			reject(err)
		case let (.right(f), .right(a)):
			resolve(f(a))
		}
//
//
//		let group = DispatchGroup()
//
//		var f: ((A) -> B)?
//		var val: A?
//
//		var errorL: E?
//		var errorR: E?
//
//		group.enter()
//		l.fork(env, { error in
////			Swift.print("ap left \(l) error")
//			errorL = error
//			group.leave()
//
//		}, { loadedF in
////			Swift.print("ap left \(l) success")
//			f = loadedF
//			group.leave()
//		})
//
//		group.enter()
//		r.fork(env, { error in
////			Swift.print("ap right \(r) error")
//			errorR = error
//			group.leave()
//		}, { loadedVal in
////			Swift.print("ap right \(r) success")
//			val = loadedVal
//			group.leave()
//		})
//
//		group.notify(queue: .main) {
//			guard localCancelled == false else {
////				Swift.print("ap local cancelled")
//				return
//			}
//
//			if let error = errorR {
////				Swift.print("ap right error")
//				reject(error)
//				return
//			}
//
//			if let error = errorL {
////				Swift.print("ap left error")
//				reject(error)
//				return
//			}
//
//			guard let f = f, let val = val else {
////				Swift.print("ap missing values")
//				return
//			}
//
////			Swift.print("ap success")
//			resolve(f(val))
//		}
		
	}, cancel: {
//		Swift.print("cancel applicative \(l) \(r)")
		localCancelled = true
		l.cancel()
		r.cancel()
//		Swift.print("applicative cancelled \(l) \(r)")
	})
}
