import Foundation

@inlinable
public func liftA2<R, E, A, B, C>(
	_ iof: SIO<R, E, (A) -> (B) -> C>,
	_ first: SIO<R, E, A>,
	_ second: SIO<R, E, B>,
	_ scheduler: Scheduler
) -> SIO<R, E, C> {
	ap(ap(iof, first, scheduler), second, scheduler)
}

@inlinable
public func ap<R, E, A, B, C>(
	_ iof: SIO<R, E, (A, B) -> C>,
	_ first: SIO<R, E, A>,
	_ second: SIO<R, E, B>,
	_ scheduler: Scheduler
) -> SIO<R, E, C> {
	liftA2(iof.map(curry), first, second, scheduler)
}

public func ap<R, E, A, B>(
	_ left: SIO<R, E, (A) -> B>,
	_ right: SIO<R, E, A>,
	_ scheduler: Scheduler
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
				
				switch (leftVal, rightVal) {
					case let (.right(ab)?, .right(a)?):
						resolved = true
						resolve(ab(a))
						
					case let (.left(e)?, .some):
						resolved = false
						reject(e)
						
					case let (.some, .left(e)?):
						resolved = false
						reject(e)
						
					case let (.left(e)?, _):
						r.cancel()
						resolved = true
						reject(e)
					
					case let (_, .left(e)?):
						l.cancel()
						resolved = true
						reject(e)
						
					default:
						return
				}
			}
		}
		
		l.fork(env, { error in
			checkContinue {
				leftVal = .left(error)
			}
			
		}, { loadedF in
			checkContinue {
				leftVal = .right(loadedF)
			}
		})
		
		r.fork(env, { error in
			checkContinue {
				rightVal = .left(error)
			}
		}, { loadedVal in
			checkContinue {
				rightVal = .right(loadedVal)
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
