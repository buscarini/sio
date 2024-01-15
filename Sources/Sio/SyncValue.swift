//
//  SyncValue.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 10/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public class SyncValue<E, A> {
	public enum State {
		case notLoaded
		case cancelled
		case loaded(Either<E, A>)
	}
	
	private let barrier = DispatchQueue(label: "es.josesanchez.barrier", attributes: .concurrent)
	private var _result: State = .notLoaded
	
	public var result: State {
		set {
			barrier.async(flags: .barrier) {
				self._result = newValue
			}
		}
		
		get {
			var res: State?
			barrier.sync {
				res = self._result
			}
			return res ?? .cancelled
		}
	}
	
	public var loaded: Bool {
		switch self.result {
		case .loaded:
			return true
		default:
			return false
		}
	}
	
	public var notLoaded: Bool {
		switch self.result {
		case .notLoaded:
			return true
		default:
			return false
		}
	}
}
