//
//  ValueStore.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import Sio

public struct ValueStore<R, E, A, B> {
	public var load: SIO<R, E, B>
	public var save: (A) -> SIO<R, E, B>
	public var remove: SIO<R, E, Void>
	
	public init(
		load: SIO<R, E, B>,
		save: @escaping (A) -> SIO<R, E, B>,
		remove: SIO<R, E, Void>
	) {
		self.load = load
		self.save = save
		self.remove = remove
	}
}
