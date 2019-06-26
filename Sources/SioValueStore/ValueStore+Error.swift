//
//  ValueStore+Error.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 26/06/2019.
//

import Foundation
import Sio

public extension ValueStore {
	func diMapError<F>(_ f: @escaping (E) -> F) -> ValueStore<R, F, A, B> {
		return ValueStore<R, F, A, B>.init(
			load: self.load.mapError(f),
			save: { a in
				self.save(a).mapError(f)
			},
			remove: self.remove.mapError(f)
		)
	}
}
