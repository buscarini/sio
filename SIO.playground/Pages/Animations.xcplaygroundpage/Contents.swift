import Foundation
import UIKit
import PlaygroundSupport
import sio


let view = UIView.init(
	frame: CGRect(
		origin: .zero,
		size: .init(width: 320, height: 720)
	)
)

view.backgroundColor = .white

let animview = UIView.init(
	frame: CGRect(
		origin: .zero,
		size: .init(width: 50, height: 50)
	)
)

animview.backgroundColor = .red

view.addSubview(animview)

let animation = Animation.default.springAnimation({
	var final = animview.frame
	final.origin.x = 50
	final.origin.y = 500
	animview.frame = final
	
}, .init(
	base: .init(
			duration: 5,
			delay: 0,
			options: [ ]
		),
		damping: 0.8,
		velocity: 1
	)
)

animation
	.delay(2)
	.fork(absurd, { _ in
		
	})

DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
	animation.cancel()
}

PlaygroundPage.current.liveView = view


