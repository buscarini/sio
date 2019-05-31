import UIKit
import sio

var str = "Hello, playground"

struct Environment {
	var resourceUrl: (String, String) -> SIO<Void, SIOError, URL>
	var loadFileUrl: (Data.ReadingOptions) -> (URL) -> SIO<Void, SIOError, Data>
	var stringFromData: (Data) -> SIO<Void, SIOError, String>
	
	static var real: Environment {
		return Environment(
			resourceUrl: bundleResourceUrl,
			loadFileUrl: loadFileUrlData,
			stringFromData: utfStringFromData
		)
	}
	
	static var mock: Environment {
		return Environment(
			resourceUrl: { _, _ in .of(URL.init(fileURLWithPath: "/tmp")) },
			loadFileUrl: { _ in { _ in .of("test".data(using: .utf8)!) } },
			stringFromData: { _ in .of("blah") }
		)
	}
}


func bundleResourceUrl(_ name: String, _ ext: String) -> SIO<Void, SIOError, URL> {
	return SIO.from { _ in
		Bundle.main.url(forResource: name, withExtension: ext)
	}
}

func loadFileUrlData(_ options: Data.ReadingOptions) -> (URL) -> SIO<Void, SIOError, Data> {
	return { url in
		SIO(catching: { _ in
			try Data.init(contentsOf: url, options: options)
		})
		.mapError { _ in SIOError.empty }
	}
}

func utfStringFromData(_ data: Data) -> SIO<Void, SIOError, String> {
	return SIO.from { _  in String.init(data: data, encoding: .utf8) }
}

let loadStringFile: SIO<Environment, SIOError, String> = SIO<Environment, Never, Environment>.environment
	.mapError(absurd)
	.flatMap { e in
		e.resourceUrl("resource", "txt")
			.flatMap(e.loadFileUrl([]))
			.flatMap(e.stringFromData)
			.require(Environment.self)
	}

loadStringFile
	.flatMap { Console.printLine($0).require(Environment.self).mapError(absurd) }
	.provide(Environment.mock)
	.fork({ error in
		error
	}, { string in
	})

//
//let loadStringFile = resourceUrl("resource", "txt")
//	.flatMap(loadFileUrl([]))
//	.flatMap(stringFromData)
//	.flatMap({ printLine($0).mapError(absurd) })
//
//loadStringFile
//	.fork({ error in
//		error
//	}, { string in
//
//	})

