//
//  IValueStore+Zip.swift
//  SioIValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 15/2/21.
//

import Foundation
import Sio

public func zip<R, K: Hashable, E, LA, LB, RA, RB>(
	_ left: IValueStore<R, K, E, LA, LB>,
	_ right: IValueStore<R, K, E, RA, RB>,
	_ scheduler: Scheduler
) -> IValueStore<R, K, E, (LA, RA), (LB, RB)> {
	.init(
		load: { k in
			zip(left.load(k), right.load(k), scheduler)
		},
		save: { k, arg in
			let (l, r) = arg
			return zip(left.save(k, l), right.save(k, r), scheduler)
		},
		remove: { k in
			zip(
				left.remove(k),
				right.remove(k),
				scheduler
			).void
		}
	)
}
