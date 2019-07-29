import Foundation
import Sio
import SioEffects



let console = Console.default
let rnd = Random()

rnd.oneOf([
	rnd.digit(),
	rnd.lowercaseLetter()
]).replicateM(6)
	.map { $0.joined() }
	.flatMap { console.printLine($0).adapt() }
	.fork({}, {})


