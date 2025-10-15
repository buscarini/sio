//
//  Optional+Utils.swift
//  Sio
//
//  Created by José Manuel Sánchez Peñarroja on 23/03/2020.
//

import Foundation

public extension Array {
	func traverse<A>(_ f: @escaping (Element) -> A?) -> [A]? {
		var result: [A] = []
		for item in self {
			guard let current = f(item) else {
				return nil
			}
			
			result.append(current)
		}
		
		return result
	}
}
