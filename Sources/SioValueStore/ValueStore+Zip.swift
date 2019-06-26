//
//  ValueStore+Zip.swift
//  SioValueStore
//
//  Created by José Manuel Sánchez Peñarroja on 26/06/2019.
//

import Foundation
import Sio

public func zip<R, E, LA, LB, RA, RB>(_ left: ValueStore<R, E, LA, LB>, _ right: ValueStore<R, E, RA, RB>) -> ValueStore<R, E, (LA, RA), (LB, RB)> {
	return ValueStore<R, E, (LA, RA), (LB, RB)>.init(
		load: zip(left.load, right.load),
		save: { arg in
			let (l, r) = arg
			return zip(left.save(l), right.save(r))
		},
		remove: zip(left.remove, right.remove).void
	)
}
