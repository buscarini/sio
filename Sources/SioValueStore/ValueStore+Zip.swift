import Foundation
import Combine

import Sio

public func zip<R, E, LA, LB, RA, RB, S: Scheduler>(
	_ left: ValueStore<R, E, LA, LB>,
	_ right: ValueStore<R, E, RA, RB>,
	_ scheduler: S
) -> ValueStore<R, E, (LA, RA), (LB, RB)> {
	return ValueStore<R, E, (LA, RA), (LB, RB)>.init(
		load: zip(left.load, right.load, scheduler),
		save: { arg in
			let (l, r) = arg
			return zip(left.save(l), right.save(r), scheduler)
		},
		remove: zip(left.remove, right.remove, scheduler).void
	)
}
