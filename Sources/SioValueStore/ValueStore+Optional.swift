//
//  ValueStore+Optional.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import Sio

public extension ValueStore {
	func optional() -> ValueStore<R, Never, A, B?> {
		return ValueStore<R, Never, A, B?>(
			load: self.load.optional(),
			save: { a in
				self.save(a).optional()
			},
			remove: self.remove.optional().void
		)
	}
	
	func set(
		_ value: A?
	) -> SIO<R, E, Void> {
		if let a = value {
			return self.save(a).void
		}
		else {
			return self.remove
		}
	}
}
