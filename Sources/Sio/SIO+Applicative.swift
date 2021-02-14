//
//  SIO+Applicative.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 20/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

@inlinable
public func liftA2<R, E, A, B, C>(
	_ iof: SIO<R, E, (A) -> (B) -> C>,
	_ first: SIO<R, E, A>,
	_ second: SIO<R, E, B>,
	_ scheduler: AnyScheduler
) -> SIO<R, E, C> {
	ap(ap(iof, first, scheduler), second, scheduler)
}

@inlinable
public func ap<R, E, A, B, C>(
	_ iof: SIO<R, E, (A, B) -> C>,
	_ first: SIO<R, E, A>,
	_ second: SIO<R, E, B>,
	_ scheduler: AnyScheduler
) -> SIO<R, E, C> {
	liftA2(iof.map(curry), first, second, scheduler)
}

//let apQueue = DispatchQueue.init(label: "ap")

public func ap<R, E, A, B>(
	_ left: SIO<R, E, (A) -> B>,
	_ right: SIO<R, E, A>,
	_ scheduler: AnyScheduler
) -> SIO<R, E, B> {
	
	let l = left
	let r = right
	
	var cancelled = false
	
	return SIO<R, E, B>({ (env, reject: @escaping (E) -> (), resolve: @escaping (B) -> ()) in
	
		var resolved: Bool?
		var leftVal: Either<E, (A) -> B>?
		var rightVal: Either<E, A>?
		
		let checkContinue: (@escaping () -> Void) -> Void = { update in
			scheduler.run {
				update()
				
				guard
					resolved == nil,
					cancelled == false,
					l.cancelled == false,
					r.cancelled == false
				else {
					return
				}
				
//				print(Thread.callStackSymbols)
//				print("ap \(leftVal) \(rightVal)")
				
				switch (leftVal, rightVal) {
				case let (.right(ab)?, .right(a)?):
					resolved = true
//					print("ap loaded both")
					resolve(ab(a))
				case let (.left(e)?, .some):
					resolved = false
//					print("ap error right")
					reject(e)
				case let (.some, .left(e)?):
					resolved = false
					
//					print("ap error left")
					
					reject(e)
					
				default:
					
//					print("other")
					
					return
				}
			}
		}
		
		l.fork(env, { error in
//			print("left error")
			checkContinue {
				leftVal = .left(error)
//				print("updated left val error")
			}
			
		}, { loadedF in
//			print("left success")
			checkContinue {
				leftVal = .right(loadedF)
//				print("updated left val success")
			}
		})
	
		r.fork(env, { error in
//			print("right error")
			checkContinue {
				rightVal = .left(error)
//				print("updated right val error")
			}
		}, { loadedVal in
//			print("right success")
			checkContinue {
				rightVal = .right(loadedVal)
//				print("updated right val success")
			}
		})
		
	}, cancel: {
		scheduler.run {
			cancelled = true
			l.cancel()
			r.cancel()
		}
	})
}
