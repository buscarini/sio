//
//  Animation.swift
//  sio-iOS
//
//  Created by José Manuel Sánchez Peñarroja on 01/06/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import UIKit

public struct Animation {
	public var animation: (@escaping () -> Void, AnimationOptions) -> UIO<Bool>
	public var springAnimation: (@escaping () -> Void, SpringAnimationOptions) -> UIO<Bool>
	
	public init(
		animation: @escaping (_ animate: @escaping () -> Void, _ options: AnimationOptions) -> UIO<Bool>,
		springAnimation: @escaping (_ animate: @escaping () -> Void, _ options: SpringAnimationOptions) -> UIO<Bool>
	) {
		self.animation = animation
		self.springAnimation = springAnimation
	}
	
	public static var `default`: Animation {
		return Animation(
			animation: defaultAnimation,
			springAnimation: defaultSpringAnimation
		)
	}
	
	static func defaultAnimation(_ animate: @escaping () -> Void, _ options: AnimationOptions) -> UIO<Bool> {
		return UIO<Bool>.init { _, _, resolve in
			UIView.animate(
				withDuration: options.duration,
				delay: options.delay,
				options: options.options,
				animations: animate,
				completion: resolve
			)
		}
	}
	
	static func defaultSpringAnimation(_ animate: @escaping () -> Void, _ options: SpringAnimationOptions) -> UIO<Bool> {
		return UIO<Bool>.init { _, _, resolve in
			UIView.animate(
				withDuration: options.base.duration,
				delay: options.base.delay,
				usingSpringWithDamping: options.damping,
				initialSpringVelocity: options.velocity,
				options: options.base.options,
				animations: animate,
				completion: resolve
			)
		}
	}
}
