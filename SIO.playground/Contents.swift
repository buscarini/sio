import UIKit
import sio

var str = "Hello, playground"

struct Environment {
	var resourceUrl: (String, String) -> SIO<Void, SIOError, URL>
	var loadFileUrl: (Data.ReadingOptions) -> (URL) -> SIO<Void, SIOError, Data>
	var stringFromData: (Data) -> SIO<Void, SIOError, String>
	var console: Console
	
	static var real: Environment {
		return Environment(
			resourceUrl: bundleResourceUrl,
			loadFileUrl: loadFileUrlData,
			stringFromData: utfStringFromData,
			console: Console.default
		)
	}
	
	static var mock: Environment {
		return Environment(
			resourceUrl: { _, _ in .of(URL.init(fileURLWithPath: "/tmp")) },
			loadFileUrl: { _ in { _ in .of("test".data(using: .utf8)!) } },
			stringFromData: { _ in .of("blah") },
			console: Console(
				printLine: { _ in .of(()) },
				getLine: { .of("hello") }
			)
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

let loadStringFile = environment(Environment.self)
	.mapError(absurd)
	.flatMap { e in
		e.resourceUrl("resource", "txt")
			.flatMap(e.loadFileUrl([]))
			.flatMap(e.stringFromData)
			.require(Environment.self)
	}

let program = loadStringFile
	.fold({ e in "Error: \(e)" }, id)
	.flatMapR( { r, s in
		r.console.printLine(s)
			.require(Environment.self)
	})

var errorEnv = Environment.real
errorEnv.resourceUrl = { _, _ in SIO<Void, SIOError, URL>.rejected(.empty) }

program
	.provide(errorEnv)
	.fork({ error in
		print("Finished with error: \(error)")
	}, { string in
		Swift.print("Finished with success: \(string)")
	})


