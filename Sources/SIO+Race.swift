//
//  SIO+Race.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 23/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public func race<R, E, A>(_ left: SIO<R, E, A>, _ right: SIO<R, E, A>) -> SIO<R, E, A> {
	var l: SIO<R, E, A> = left
	var r: SIO<R, E, A> = right
	return SIO<R, E, A>.init({ env, reject, resolve in
		
		let queue = DispatchQueue.init(label: "Race Queue")
		
		var finished = false
		var leftFailed = false
		var rightFailed = false
		
		l.fork(env, { errorL in
			
			var ret = false
			queue.sync {
				leftFailed = true
				ret = finished == true || rightFailed == false
			}
			
			guard ret == false else {
				return
			}

			reject(errorL)
			
		}, { successL in
			
			guard finished == false else { return }
			
			queue.sync {
				finished = true
			}
			
			resolve(successL)
			r.cancel()
		})
		
		r.fork(env, { errorR in
			
			var ret = false
			
			queue.sync {
				rightFailed = true
				ret = finished == true || leftFailed == false
			}
			
			guard ret == false else {
				return
			}
			
			reject(errorR)
		}, { successR in
			
			guard finished == false else { return }
			
			queue.sync {
				finished = true
			}
			
			resolve(successR)
			l.cancel()
		})
	}) {
		l.cancel()
		r.cancel()
	}
}
