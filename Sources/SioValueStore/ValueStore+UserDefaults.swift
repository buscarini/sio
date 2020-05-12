//
//  ValueStore+UserDefaults.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 26/06/2019.
//

import Foundation
import Sio
import SioCodec

public protocol PropertyListValue {}

extension NSData: PropertyListValue {}
extension NSString: PropertyListValue {}
extension NSNumber: PropertyListValue {}
extension NSDate: PropertyListValue {}
extension NSArray: PropertyListValue {}
extension NSDictionary: PropertyListValue {}

extension Data: PropertyListValue {}
extension String: PropertyListValue {}
extension Array: PropertyListValue {}
extension Dictionary: PropertyListValue {}

extension Bool: PropertyListValue {}
extension Int: PropertyListValue {}
extension Int8: PropertyListValue {}
extension Int16: PropertyListValue {}
extension Int32: PropertyListValue {}
extension Int64: PropertyListValue {}
extension UInt: PropertyListValue {}
extension UInt8: PropertyListValue {}
extension UInt16: PropertyListValue {}
extension UInt32: PropertyListValue {}
extension UInt64: PropertyListValue {}

extension Float: PropertyListValue {}
extension Double: PropertyListValue {}

public extension ValueStore where A: PropertyListValue, E == Void {
	static func rawPreference(_ key: String) -> ValueStoreA<R, Void, A> {
		ValueStoreA<R, Void, A>(
			load: SIO.sync({ _ in
				guard let value = (UserDefaults.standard.object(forKey: key) as? A) else {
					return .left(())
				}
				
				return .right(value)
			}),
			save: { value in
				SIO.sync({ _ in
					UserDefaults.standard.set(value, forKey: key)
					return .right(value)
				})
			},
			remove: SIO.sync({ _ in
				UserDefaults.standard.removeObject(forKey: key)
				return .right(())
			})
		)
	}
}

public extension ValueStore where A: Codable, A == B, R == Void, E == ValueStoreError {
	static func jsonPreference(_ key: String) -> ValueStoreA<Void, ValueStoreError, A> {
		ValueStoreA<Void, Void, Data>
			.rawPreference(key)
			.diMapError { _ in .noData }
			.coded(Codec.json.mapError(ValueStoreError.encoding))
	}
}
