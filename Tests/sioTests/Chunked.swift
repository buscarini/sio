import XCTest

import CombineSchedulers

import Sio

class Chunked: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testChunks() {
		 let scheduler = DispatchQueue.test

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

		scheduler.advance(by: .seconds(1.0))
		scheduler.advance(by: .seconds(1.0))
		
		self.waitForExpectations(timeout: 2.5, handler: nil)
    }
}
