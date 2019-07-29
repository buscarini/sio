import Foundation
import Sio
import SioEffects
import CoreGraphics
import UIKit


let console = Console.default
let rnd = Random()

let segment = rnd.oneOf([
	rnd.digit(),
	rnd.uppercaseLetter()
])
	.replicateM(6)
	.map { $0.joined() }


segment
	.replicateM(3)
	.map { $0.joined(separator: "-") }
	.flatMap { console.printLine($0).adapt() }
	.fork({ _ in }, {})

let point = zip(rnd.int(-10...10), rnd.int(-10...10))
	.map(CGPoint.init)

point
	.map { "\($0)" }
	.flatMap { console.printLine($0).adapt() }
	.fork({ _ in }, {})


let colorComponent = rnd.float(0...1).map(CGFloat.init)

let color = zip4(
	colorComponent,
	colorComponent,
	colorComponent,
	SIO<Void, Never, CGFloat>.of(1)
).map { r, g, b, a in
	UIColor.init(red: r, green: g, blue: b, alpha: a)
}
	
	
color
	.map { "\($0)" }
	.flatMap { console.printLine($0).adapt() }
	.fork({ _ in }, {})


