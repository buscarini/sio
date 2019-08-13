//
//  SIO+Random.swift
//  sio-iOS Tests
//
//  Created by José Manuel Sánchez Peñarroja on 24/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation
import Sio

public struct Random {
	public var int = Default.randomInt
	public var uint = Default.randomUInt
	public var float = Default.randomFloat
	public var double = Default.randomDouble

	public init(
		int: @escaping (ClosedRange<Int>) -> SIO<Ref<AnyRandomNumberGenerator>, Never, Int> = Default.randomInt,
		uint: @escaping (ClosedRange<UInt>) -> SIO<Ref<AnyRandomNumberGenerator>, Never, UInt> = Default.randomUInt,
		float: @escaping (ClosedRange<Float>) -> SIO<Ref<AnyRandomNumberGenerator>, Never, Float> = Default.randomFloat,
		double: @escaping (ClosedRange<Double>) -> SIO<Ref<AnyRandomNumberGenerator>, Never, Double> = Default.randomDouble
	) {
		self.int = int
		self.uint = uint
		self.float = float
		self.double = double
	}
	
	public func element<A>(_ from: [A]) -> SIO<Ref<AnyRandomNumberGenerator>, Never, A?> {
		guard from.count > 0 else {
			return .of(nil)
		}
		
		return self.int(0...(from.count - 1))
			.map { index in
				from[index]
			}
	}
	
	public enum Default {
		public static func randomInt(_ range: ClosedRange<Int>) -> SIO<Ref<AnyRandomNumberGenerator>, Never, Int> {
			return SIO<Ref<AnyRandomNumberGenerator>, Never, Int>.init({ r, reject, resolve in
				resolve(Int.random(in: range, using: &r.state))
			})
		}
		
		public static func randomUInt(_ range: ClosedRange<UInt>) -> SIO<Ref<AnyRandomNumberGenerator>, Never, UInt> {
			return SIO<Ref<AnyRandomNumberGenerator>, Never, UInt>.init({ r, reject, resolve in
				resolve(UInt.random(in: range, using: &r.state))
			})
		}
		
		public static func randomFloat(_ range: ClosedRange<Float>) -> SIO<Ref<AnyRandomNumberGenerator>, Never, Float> {
			return SIO<Ref<AnyRandomNumberGenerator>, Never, Float>.init({ r, reject, resolve in
				resolve(Float.random(in: range, using: &r.state))
			})
		}
		
		public static func randomDouble(_ range: ClosedRange<Double>) -> SIO<Ref<AnyRandomNumberGenerator>, Never, Double> {
			return SIO<Ref<AnyRandomNumberGenerator>, Never, Double>.init({ r, reject, resolve in
				resolve(Double.random(in: range, using: &r.state))
			})
		}
		
		public static func element<C: Collection>(in c: C) -> SIO<Ref<AnyRandomNumberGenerator>, Void, C.Element> {
			return SIO<Ref<AnyRandomNumberGenerator>, Void, C.Element>.init({ r, reject, resolve in
				if let value = c.randomElement(using: &r.state) {
					resolve(value)
				}
				else {
					reject(())
				}
			})
		}
	}
}

public extension Random {
	func oneOf<A>(_ sios: [SIO<Ref<AnyRandomNumberGenerator>, Void, A>]) -> SIO<Ref<AnyRandomNumberGenerator>, Void, A> {
		let chosen = Random.Default.element(in: sios)
		
		return chosen
			.flatMap { $0 }
	}
	
	func randomLetter(from: Unicode.Scalar, to: Unicode.Scalar) -> SIO<Ref<AnyRandomNumberGenerator>, Void, String> {
		return SIO<Ref<AnyRandomNumberGenerator>, Void, ClosedRange<UInt32>>
			.of(from.value...to.value)
			.read()
			.map { arg -> String? in
				let (r, range) = arg
				return range.randomElement(using: &r.state)
					.flatMap(Unicode.Scalar.init(_:))
					.flatMap(String.init)
			}
			.flatMap { s in
				.from(s, ())
			}
	}
	
	func lowercaseLetter() -> SIO<Ref<AnyRandomNumberGenerator>, Void, String> {
		return randomLetter(from: Unicode.Scalar("a"), to: Unicode.Scalar("z"))
	}
	
	func uppercaseLetter() -> SIO<Ref<AnyRandomNumberGenerator>, Void, String> {
		return randomLetter(from: Unicode.Scalar("A"), to: Unicode.Scalar("Z"))
	}
	
	func digit() -> SIO<Ref<AnyRandomNumberGenerator>, Void, String> {
		return randomLetter(from: Unicode.Scalar("0"), to: Unicode.Scalar("9"))
	}
}
