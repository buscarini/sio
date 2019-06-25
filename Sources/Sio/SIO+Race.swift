//
//  SIO+Race.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 23/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public func race<R, E, A>(_ left: SIO<R, E, A>, _ right: SIO<R, E, A>) -> SIO<R, E, A> {
	let l: SIO<R, E, A> = left
	let r: SIO<R, E, A> = right
	return SIO<R, E, A>.init({ env, reject, resolve in
		
		let resolved = SyncValue<Never, Bool>()
		let leftVal = SyncValue<E, A>()
		let rightVal = SyncValue<E, A>()
		
		let checkContinue = {
			guard resolved.notLoaded else { return }
			
			if l.cancelled {
				leftVal.result = .cancelled
			}
			
			if r.cancelled {
				rightVal.result = .cancelled
			}
			
			switch (leftVal.result, rightVal.result) {
			case let (.loaded(.right(a)), _):
				resolved.result = .loaded(.right(true))
				r.cancel()
				resolve(a)
			case let (.loaded(.left(e)), _):
				resolved.result = .loaded(.right(true))
				r.cancel()
				reject(e)
			case let (_, .loaded(.left(e))):
				resolved.result = .loaded(.right(true))
				l.cancel()
				reject(e)
			case let (_, .loaded(.right(a))):
				resolved.result = .loaded(.right(true))
				l.cancel()
				resolve(a)
			default:
				return
			}
		}
		
		l.fork(env, { errorL in
			
//			var ret = false
			
			leftVal.result = .loaded(.left(errorL))
			checkContinue()
			
//			queue.sync {
//				leftFailed = true
//				ret = finished == true || rightFailed == false
//			}
//
//			guard ret == false else {
//				return
//			}
//
//			reject(errorL)
			
		}, { successL in

			leftVal.result = .loaded(.right(successL))
			checkContinue()
			
//			guard finished == false else { return }
//
//			queue.sync {
//				finished = true
//			}
//
//			resolve(successL)
//			r.cancel()
		})
		
		r.fork(env, { errorR in
			
			rightVal.result = .loaded(.left(errorR))
			checkContinue()
			
//			var ret = false
//
//			queue.sync {
//				rightFailed = true
//				ret = finished == true || leftFailed == false
//			}
//
//			guard ret == false else {
//				return
//			}
//
//			reject(errorR)
		}, { successR in

			rightVal.result = .loaded(.right(successR))
			checkContinue()
			
//			guard finished == false else { return }
//
//			queue.sync {
//				finished = true
//			}
//
//			resolve(successR)
//			l.cancel()
		})
	}) {
		l.cancel()
		r.cancel()
	}
}
