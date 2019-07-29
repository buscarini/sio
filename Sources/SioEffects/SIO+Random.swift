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
		int: @escaping (Range<Int>) -> SIO<Void, Never, Int> = Default.randomInt,
		uint: @escaping (Range<UInt>) -> SIO<Void, Never, UInt> = Default.randomUInt,
		float: @escaping (Range<Float>) -> SIO<Void, Never, Float> = Default.randomFloat,
		double: @escaping (Range<Double>) -> SIO<Void, Never, Double> = Default.randomDouble
	) {
		self.int = int
		self.uint = uint
		self.float = float
		self.double = double
	}
	
	public func element<A>(_ from: [A]) -> SIO<Void, Never, A?> {
		guard from.count > 0 else {
			return .of(nil)
		}
		
		return self.int(0..<from.count)
			.map { index in
				from[index]
			}
	}
	
	public enum Default {
		public static func randomInt(_ range: Range<Int>) -> SIO<Void, Never, Int> {
			return SIO<Void, Never, Int>.init({ _, reject, resolve in
				resolve(Int.random(in: range))
			})
		}
		
		public static func randomUInt(_ range: Range<UInt>) -> SIO<Void, Never, UInt> {
			return SIO<Void, Never, UInt>.init({ _ , reject, resolve in
				resolve(UInt.random(in: range))
			})
		}
		
		public static func randomFloat(_ range: Range<Float>) -> SIO<Void, Never, Float> {
			return SIO<Void, Never, Float>.init({ _ , reject, resolve in
				resolve(Float.random(in: range))
			})
		}
		
		public static func randomDouble(_ range: Range<Double>) -> SIO<Void, Never, Double> {
			return SIO<Void, Never, Double>.init({ _ , reject, resolve in
				resolve(Double.random(in: range))
			})
		}
		
		public static func element<C: Collection>(in c: C) -> SIO<Void, Void, C.Element> {
			return SIO<Void, Void, C.Element>.from({
				c.randomElement()
			})
		}
	}
}

public extension Random {
	func oneOf<R, A>(_ sios: [SIO<R, Void, A>]) -> SIO<R, Void, A> {
		let chosen = Random.Default.element(in: sios)
			.require(R.self)
		
		return chosen
			.flatMap { $0 }
	}
	
	func randomLetter(from: Unicode.Scalar, to: Unicode.Scalar) -> SIO<Void, Void, String> {
		return SIO<Void, Void, String>.from {
			let range = from.value...to.value
			return range.randomElement()
				.flatMap(Unicode.Scalar.init(_:))
				.flatMap(String.init)
		}
	}
	
	func lowercaseLetter() -> SIO<Void, Void, String> {
		return randomLetter(from: Unicode.Scalar("a"), to: Unicode.Scalar("z"))
	}
	
	func uppercaseLetter() -> SIO<Void, Void, String> {
		return randomLetter(from: Unicode.Scalar("A"), to: Unicode.Scalar("Z"))
	}
	
	func digit() -> SIO<Void, Void, String> {
		return randomLetter(from: Unicode.Scalar("0"), to: Unicode.Scalar("9"))
	}
}
