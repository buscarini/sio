//
//  PathUtils.swift
//  SioEffectsTests
//
//  Created by José Manuel Sánchez Peñarroja on 02/06/2020.
//

import Foundation
import Sio

public enum PathUtils {
	static var tmpPath: FolderURL {
		FolderURL(url: FileManager.default.temporaryDirectory)!
	}
}
