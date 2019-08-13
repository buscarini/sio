import Foundation
import Sio
import CoreGraphics

let state = Ref<Int>.init(0)

SIO<Ref<Int>, Never, String>
	.of("blah")
	.modify { $0 + 1 }
//	.read()
	.get()
	.fork(state, absurd, { result in
		print(result)
		print(state.state)
	})


state.state



