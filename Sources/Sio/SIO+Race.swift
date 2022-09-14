//
//  SIO+Race.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 23/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

//public func race<R, E, A>(_ left: SIO<R, E, A>, _ right: SIO<R, E, A>) -> SIO<R, E, A> {
//	let l: SIO<R, E, A> = left
//	let r: SIO<R, E, A> = right
//	return SIO<R, E, A>.init({ env, reject, resolve in
//		
//		let resolved = SyncValue<Never, Bool>()
//		let leftVal = SyncValue<E, A>()
//		let rightVal = SyncValue<E, A>()
//		
//		let checkContinue = {
//			guard resolved.notLoaded else {
//				return
//			}
//			
//			if l.cancelled {
//				leftVal.result = .cancelled
//			}
//			
//			if r.cancelled {
//				rightVal.result = .cancelled
//			}
//			
//			switch (leftVal.result, rightVal.result) {
//			case let (.loaded(.right(a)), _):
//				resolved.result = .loaded(.right(true))
//				r.cancel()
//				resolve(a)
//			case let (_, .loaded(.right(a))):
//				resolved.result = .loaded(.right(true))
//				l.cancel()
//				resolve(a)
//			default:
//				return
//			}
//		}
//		
//		l.fork(env, { errorL in
//			leftVal.result = .loaded(.left(errorL))
//			checkContinue()
//		}, { successL in
//			leftVal.result = .loaded(.right(successL))
//			checkContinue()
//		})
//		
//		r.fork(env, { errorR in
//			rightVal.result = .loaded(.left(errorR))
//			checkContinue()
//		}, { successR in
//
//			rightVal.result = .loaded(.right(successR))
//			checkContinue()
//		})
//	}) {
//		l.cancel()
//		r.cancel()
//	}
//}
