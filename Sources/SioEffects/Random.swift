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
		environment(Ref<AnyRandomNumberGenerator>.self).flatMap { r in
			SIO<Ref<AnyRandomNumberGenerator>, Never, A?>.await {
				await r.update { generator in
					from.randomElement(using: &generator)
				}
			}
		}
	}
	
	public enum Default {
		public static func randomInt(_ range: ClosedRange<Int>) -> SIO<Ref<AnyRandomNumberGenerator>, Never, Int> {
			environment(Ref<AnyRandomNumberGenerator>.self).flatMap { r in
				SIO<Ref<AnyRandomNumberGenerator>, Never, Int>.await {
					await r.update { generator in
						Int.random(in: range, using: &generator)
					}
				}
			}
		}
		
		public static func randomUInt(_ range: ClosedRange<UInt>) -> SIO<Ref<AnyRandomNumberGenerator>, Never, UInt> {
			environment(Ref<AnyRandomNumberGenerator>.self).flatMap { r in
				SIO<Ref<AnyRandomNumberGenerator>, Never, UInt>.await {
					await r.update { generator in
						UInt.random(in: range, using: &generator)
					}
				}
			}
		}
		
		public static func randomFloat(_ range: ClosedRange<Float>) -> SIO<Ref<AnyRandomNumberGenerator>, Never, Float> {
			environment(Ref<AnyRandomNumberGenerator>.self).flatMap { r in
				SIO<Ref<AnyRandomNumberGenerator>, Never, Float>.await {
					await r.update { generator in
						Float.random(in: range, using: &generator)
					}
				}
			}
		}
		
		public static func randomDouble(_ range: ClosedRange<Double>) -> SIO<Ref<AnyRandomNumberGenerator>, Never, Double> {
			environment(Ref<AnyRandomNumberGenerator>.self).flatMap { r in
				SIO<Ref<AnyRandomNumberGenerator>, Never, Double>.await {
					await r.update { generator in
						Double.random(in: range, using: &generator)
					}
				}
			}
		}
		
		public static func element<C: Collection>(in c: C) -> SIO<Ref<AnyRandomNumberGenerator>, Void, C.Element> {
			environment(Ref<AnyRandomNumberGenerator>.self).flatMap { r in
				SIO<Ref<AnyRandomNumberGenerator>, Void, C.Element?>.await {
					await r.update { generator in
						c.randomElement(using: &generator)
					}
				}.fromOptional()
			}
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
			.flatMap { arg in
				SIO.await {
					let (r, range) = arg
					let element = await r.update { state in
						range.randomElement(using: &state)
					}
					
					return element
						.flatMap(Unicode.Scalar.init(_:))
						.flatMap(String.init)
				}
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
