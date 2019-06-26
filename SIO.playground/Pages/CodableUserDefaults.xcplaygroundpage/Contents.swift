import Foundation
import PlaygroundSupport

import Sio
import SioValueStore

struct User: Equatable, Codable {
	var name: String
	var index: Int
}

let store = ValueStoreA<Void, Error, User>.codablePreference("user")

let john = User(name: "John", index: 7)

store.save(john).flatMap { _ in
	store.load
	}
	.fork({ _ in
		print("ERROR")
		PlaygroundPage.current.finishExecution()
	}, { value in
		assert(value == john)
		print(value)
		PlaygroundPage.current.finishExecution()
	})

PlaygroundPage.current.needsIndefiniteExecution = true
