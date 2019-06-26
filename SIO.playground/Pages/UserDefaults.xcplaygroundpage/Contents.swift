import Foundation
import PlaygroundSupport

import Sio
import SioValueStore

let store = ValueStoreA<Void, Void, Int64>.rawPreference("value")
	
store.save(7).flatMap { _ in
	store.load
}
.fork({ _ in
	print("ERROR")
	PlaygroundPage.current.finishExecution()
}, { value in
	assert(value == 7)
	print(value)
	PlaygroundPage.current.finishExecution()
})

PlaygroundPage.current.needsIndefiniteExecution = true
