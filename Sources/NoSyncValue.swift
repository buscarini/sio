//
//  NoSyncValue.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 10/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public class NoSyncValue<E, A> {
	public enum State<E, A> {
		case notLoaded
		case cancelled
		case loaded(Either<E, A>)
	}
	
	public var result: State<E, A> = .notLoaded
	
	public var notLoaded: Bool {
		switch self.result {
		case .notLoaded:
			return true
		default:
			return false
		}
	}
}
