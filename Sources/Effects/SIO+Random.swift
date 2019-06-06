//
//  SIO+Random.swift
//  sio-iOS Tests
//
//  Created by José Manuel Sánchez Peñarroja on 24/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public struct Random {
	public var int = randomInt
	public var uint = randomUInt
	public var float = randomFloat
	public var double = randomDouble
//	public var element = randomElement
//	public var shuffled = randomShuffled
	
	public init(
		int: @escaping (Range<Int>) -> SIO<Void, Never, Int>,
		uint: @escaping (Range<UInt>) -> SIO<Void, Never, UInt>,
		float: @escaping (Range<Float>) -> SIO<Void, Never, Float>,
		double: @escaping (Range<Double>) -> SIO<Void, Never, Double>
//		element: @escaping ([A]) -> SIO<Void, Never, A?>,
//		shuffled: @escaping ([A]) -> SIO<Void, Never, [A]>
	) {
		self.int = int
		self.uint = uint
		self.float = float
		self.double = double
//		self.element = element
//		self.shuffled = shuffled
	}
	
	static func randomInt(_ range: Range<Int>) -> SIO<Void, Never, Int> {
		return SIO<Void, Never, Int>.init({ _, reject, resolve in
			resolve(Int.random(in: range))
		})
	}
	
	static func randomUInt(_ range: Range<UInt>) -> SIO<Void, Never, UInt> {
		return SIO<Void, Never, UInt>.init({ _ , reject, resolve in
			resolve(UInt.random(in: range))
		})
	}
	
	static func randomFloat(_ range: Range<Float>) -> SIO<Void, Never, Float> {
		return SIO<Void, Never, Float>.init({ _ , reject, resolve in
			resolve(Float.random(in: range))
		})
	}
	
	static func randomDouble(_ range: Range<Double>) -> SIO<Void, Never, Double> {
		return SIO<Void, Never, Double>.init({ _ , reject, resolve in
			resolve(Double.random(in: range))
		})
	}
	
	static func randomElement<A>(_ array: [A]) -> SIO<Void, Never, A?> {
		return SIO<Void, Never, A?>.init({ _, reject, resolve in
			resolve(array.randomElement())
		})
	}
	
	static func randomShuffled<A>(_ array: [A]) -> SIO<Void, Never, [A]> {
		return SIO<Void, Never, [A]>.init({ _, reject, resolve in
			resolve(array.shuffled())
		})
	}
}
