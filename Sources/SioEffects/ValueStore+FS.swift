//
//  ValueStore+FS.swift
//  SioEffects
//
//  Created by José Manuel Sánchez Peñarroja on 07/12/2019.
//

import Foundation
import Sio
import SioCodec
import SioValueStore

public extension ValueStore where A == Data, B == Data, E == Error, R == FS {
	static func fileData(_ url: FileURL) -> ValueStoreA<FS, Error, Data> {
		ValueStoreA<FS, Error, Data>.init(
			load: environment(FS.self)
				.flatMap { fs in
					fs.readFile(url).require(FS.self)
				},
			save: { data in
				environment(FS.self)
					.flatMap { fs in
						fs.writeFile(data, url)
							.require(FS.self)
							.const(data)
					}
			},
			remove: environment(FS.self)
				.flatMap { fs in
					fs.removeFile(url).require(FS.self)
				}
		)
	}
}

public extension ValueStoreA where A: Codable {
	static func jsonFile(
		_ url: FileURL,
		decoder: JSONDecoder = JSONDecoder(),
		encoder: JSONEncoder = JSONEncoder()
	) -> ValueStoreA<FS, Error, A> {
		ValueStoreA<FS, Error, Data>.fileData(url)
			>>> Codec.jsonCodec(decoder, encoder)
	}
}
