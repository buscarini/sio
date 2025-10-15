import Foundation
import Combine

import Sio

public func zip<R, K: Hashable, E, LA, LB, RA, RB, S: Scheduler>(
	_ left: IValueStore<R, K, E, LA, LB>,
	_ right: IValueStore<R, K, E, RA, RB>,
	_ scheduler: S
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
