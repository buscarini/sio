//
//  SIO+Random.swift
//  sio-iOS Tests
//
//  Created by José Manuel Sánchez Peñarroja on 24/05/2019.
//  Copyright © 2019 sio. All rights reserved.
//

import Foundation

public extension SIO {
	static var randomInt: SIO<Range<Int>, Never, Int> {
		return SIO<Range<Int>, Never, Int>.init({ range , reject, resolve in
			resolve(Int.random(in: range))
		})
	}
	
	static var randomUInt: SIO<Range<UInt>, Never, UInt> {
		return SIO<Range<UInt>, Never, UInt>.init({ range , reject, resolve in
			resolve(UInt.random(in: range))
		})
	}
	
	static var randomFloat: SIO<Range<Float>, Never, Float> {
		return SIO<Range<Float>, Never, Float>.init({ range , reject, resolve in
			resolve(Float.random(in: range))
		})
	}
	
	static var randomFloat80: SIO<Range<Float80>, Never, Float80> {
		return SIO<Range<Float80>, Never, Float80>.init({ range , reject, resolve in
			resolve(Float80.random(in: range))
		})
	}
	
	static var randomDouble: SIO<Range<Double>, Never, Double> {
		return SIO<Range<Double>, Never, Double>.init({ range , reject, resolve in
			resolve(Double.random(in: range))
		})
	}
	
	static var randomElement: SIO<[A], Never, A?> {
		return SIO<[A], Never, A?>.init({ values, reject, resolve in
			resolve(values.randomElement())
		})
	}
	
	static var shuffled: SIO<[A], Never, [A]> {
		return SIO<[A], Never, [A]>.init({ values, reject, resolve in
			resolve(values.shuffled())
		})
	}
}
