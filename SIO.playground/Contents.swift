import UIKit
import sio

var str = "Hello, playground"


func resourceUrl(_ name: String, _ ext: String) -> SIO<Void, SIOError, URL>{
	return SIO.from { _ in
		Bundle.main.url(forResource: name, withExtension: ext)
	}
}

func loadFileUrl(_ options: Data.ReadingOptions) -> (URL) -> SIO<Void, SIOError, Data> {
	return { url in
		SIO(catching: { _ in
			try Data.init(contentsOf: url, options: options)
		})
		.mapError { _ in SIOError.empty }
	}
}

func stringFromData(_ data: Data) -> SIO<Void, SIOError, String> {
	return SIO.from { _  in String.init(data: data, encoding: .utf8) }
}

let loadStringFile = resourceUrl("resource", "txt")
	.flatMap(loadFileUrl([]))
	.flatMap(stringFromData)
	.flatMap({ printLine($0).mapError(absurd) })

loadStringFile
	.fork({ error in
		error
	}, { string in
		
	})

