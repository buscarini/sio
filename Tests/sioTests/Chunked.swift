//
//  Chunked.swift
//  Task
//
//  Created by José Manuel Sánchez Peñarroja on 13/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Sio

class Chunked: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testChunks() {
		let scheduler = TestScheduler()

		let values = Array(1...10)
		let tasks = values
				.map { IO<Error, Int>.of($0) }
				.map(delayed(1, scheduler))
		
		let taskChunks = tasks.chunked(by: 5) // [[task1, …, task5],[task6, …, task10]]
			.map {
				parallel($0, scheduler)
			} // [ task[], task[] ]
		
		let expectation = self.expectation(description: "tasks completed")
		
//		let now = Date()

		sequence(taskChunks) // task[]
			.fork((), { _ in
				XCTFail()
			},
			{ results in
				XCTAssert(results == values)
//				XCTAssert(-now.timeIntervalSinceNow > 2.0)
				
				expectation.fulfill()
			})

		scheduler.advance(1)
		scheduler.advance(1)

		self.waitForExpectations(timeout: 2.5, handler: nil)
    }
}
