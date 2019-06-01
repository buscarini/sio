//
//  AnimationOptions.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 01/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import UIKit

public struct AnimationOptions {
	public var duration: TimeInterval
	public var delay: TimeInterval
	public var options: UIView.AnimationOptions
	
	public init(
		duration: TimeInterval,
		delay: TimeInterval,
		options: UIView.AnimationOptions
	) {
		self.duration = duration
		self.delay = delay
		self.options = options
	}
}
