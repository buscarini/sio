//
//  ValueStore.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 25/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import Sio

// Represents a value store. It can be implemented to use a file, network calls, preferences, etc.
public struct ValueStore<R, E, A, B> {
	public var _load: () -> SIO<R, E, B>
	public var save: (A) -> SIO<R, E, B>
	public var _remove: () -> SIO<R, E, Void>
	
	public init(
		load: @autoclosure @escaping () -> SIO<R, E, B>,
		save: @escaping (A) -> SIO<R, E, B>,
		remove: @autoclosure @escaping () -> SIO<R, E, Void>
	) {
		self._load = load
		self.save = save
		self._remove = remove
	}
	
	public var load: SIO<R, E, B> {
		get {
			self._load()
		}
		set {
			self._load = { newValue }
		}
	}
	
	public var remove: SIO<R, E, Void> {
		get {
			self._remove()
		}
		set {
			self._remove = { newValue }
		}
	}
}
