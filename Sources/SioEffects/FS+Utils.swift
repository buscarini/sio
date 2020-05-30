//
//  FS+Utils.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 22/03/2020.
//

import Foundation
import Sio

public extension FS {
	func resource(
		_ bundle: Bundle,
		name: String,
		extension ext: String
	) -> IO<Void, FileURL> {
		IO.from(
			bundle.url(forResource: name, withExtension: ext),
			()
		)
		.flatMap { url in
			IO.from(
				FileURL.init(url: url),
				()
			)
		}
	}
	
	func read(
		_ bundle: Bundle,
		name: String,
		extension ext: String
	) -> IO<Error, Data> {
		resource(bundle, name: name, extension: ext)
			.mapError { _ in
				NSError(
					domain: "Bundle",
					code: NSFileReadNoSuchFileError,
					userInfo: [ NSLocalizedDescriptionKey: "Resource not found" ]
				)
			}
			.flatMap(
				self.readFile
			)
	}
	
	func readStr(
		_ bundle: Bundle,
		name: String,
		extension ext: String
	) -> IO<Error, String> {
		read(bundle, name: name, extension: ext)
			.flatMap { data in
				.from(String.init(data: data, encoding: .utf8), NSError.init(
					domain: "Encoding",
					code: NSFileReadUnknownStringEncodingError,
					userInfo: [ NSLocalizedDescriptionKey: "String not in utf8" ]
				))
		}
	}
}
