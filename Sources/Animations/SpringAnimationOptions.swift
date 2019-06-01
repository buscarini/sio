//
//  SpringAnimationOptions.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 01/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import UIKit

public struct SpringAnimationOptions {
	public var base: AnimationOptions
	public var damping: CGFloat
	public var velocity: CGFloat
	
	public init(
		base: AnimationOptions,
		damping: CGFloat,
		velocity: CGFloat
	) {
		self.base = base
		self.damping = damping
		self.velocity = velocity
	}
}
