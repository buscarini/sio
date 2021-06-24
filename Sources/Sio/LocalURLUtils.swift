//
//  LocalURL.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 24/12/2019.
//

import Foundation

// MARK: Utils
public func join<RTarget: PathTarget>(_ left: AbsoluteLocalURL<IsFolder>, _ right: RelativeLocalURL<RTarget>) -> AbsoluteLocalURL<RTarget> {
	left.map {
		$0.appendingPathComponent(right.rawValue)
	}
	.coerced(target: RTarget.self)
}

public func <> <RTarget: PathTarget>(_ left: AbsoluteLocalURL<IsFolder>, _ right: RelativeLocalURL<RTarget>) -> AbsoluteLocalURL<RTarget> {
	return join(left, right)
}

public func join<RTarget: PathTarget>(
	_ left: RelativeLocalURL<IsFolder>,
	_ right: RelativeLocalURL<RTarget>) -> RelativeLocalURL<RTarget> {
	left.map { left in
		left + "/" + right.rawValue
	}
	.coerced(target: RTarget.self)
}

public func <> <RTarget: PathTarget>(_ left: RelativeLocalURL<IsFolder>, _ right: RelativeLocalURL<RTarget>) -> RelativeLocalURL<RTarget> {
	return join(left, right)
}
