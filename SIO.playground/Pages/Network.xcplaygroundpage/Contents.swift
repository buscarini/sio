import Foundation
import Sio
import SioEffects
import SioNetwork
import SioCodec

import PlaygroundSupport

Network()
	.get("https://postman-echo.com/get")
	.map { $0.0 }
	.decode(
		Codec.utf8.mapError(const(NetworkError.unknown))
	)
	.fork({ e in
		PlaygroundPage.current.finishExecution()
	}) { result in
		print(result)
		
		PlaygroundPage.current.finishExecution()
	}


//let url = RemoteURL.init("https://postman-echo.com/get")

PlaygroundPage.current.needsIndefiniteExecution = true
