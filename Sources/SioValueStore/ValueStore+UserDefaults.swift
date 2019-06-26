//
//  ValueStore+UserDefaults.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 26/06/2019.
//

import Foundation
import Sio

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

public extension ValueStore where A: PropertyListValue {
	static func rawPreference(_ key: String) -> ValueStoreA<R, Void, A> {
		return ValueStoreA<R, Void, A>(
			load: SIO.init({ _ in
				guard let value = (UserDefaults.standard.object(forKey: key) as? A) else {
					return .left(())
				}
				
				return .right(value)
			}),
			save: { value in
				return SIO.init({ _ in
					UserDefaults.standard.set(value, forKey: key)
					return .right(value)
				})
			},
			remove: SIO.init({ _ in
				UserDefaults.standard.removeObject(forKey: key)
				return .right(())
			})
		)
	}
}

//public extension ValueStore where A: Codable {
//	static func codablePreference(_ key: String) -> ValueStoreA<R, Error, A> {
//		return ValueStoreA<R, Error, A>(
//			load: SIO<R, Error, A>.init({ _ in
//				
//
//
//			})
//
//
//
//			{ (env) -> Task<AppError, T> in
//			return UserDefaults.standard.load(key: key, T.self, log: env.log)
//		}, save: { value, env in
//			return UserDefaults.standard.save(value, forKey: key, log: env.log).flatMap { value in
//				guard let value = value else {
//					return Task.rejected(AppError.noData)
//				}
//
//				return Task.of(value)
//			}
//		}, remove: { _ in
//			return UserDefaults.standard.clear(key)
//		})
//	}
//}
