//
//  SIO+Events.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 27/06/2019.
//

import Foundation

public extension SIO {
	@inlinable
	func onCancellation(_ task: SIO<Void, Never, Void>) -> SIO<R, E, A> {
		var work: Work<E, A>?
		
		var res = SIO.init({ r, reject, resolve in
			work = self.fork(r, reject, resolve)
		})
		
		res.onCancel = {
			work?.cancel()
			
			task.fork(absurd, { _ in })
		}

		return res
	}
	
	@inlinable
	func onCompletion(_ task: SIO<Void, Never, Void>) -> SIO<R, E, A> {
		return self.biFlatMap({ e in
			task
				.adapt()
				.flatMap { _ in
					.rejected(e)
				}
			
		}, { a in
			task
				.adapt()
				.const(a)
		})
	}
	
	@inlinable
	func onTermination(_ task: SIO<Void, Never, Void>) -> SIO<R, E, A> {
		self.onCompletion(task).onCancellation(task)
	}
}
