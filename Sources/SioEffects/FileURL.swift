//
//  FileURL.swift
//  SioTests
//
//  Created by José Manuel Sánchez Peñarroja on 02/07/2019.
//

import Foundation

public struct FileURL: Equatable, Hashable {
	public var rawValue: URL
	
	public init?(_ rawValue: URL) {
		guard rawValue.isFileURL else {
			return nil
		}
		
		self.rawValue = rawValue
	}
}
