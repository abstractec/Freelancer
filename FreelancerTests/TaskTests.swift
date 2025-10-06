//
//  TaskTests.swift
//  FreelancerTests
//
//  Created by John Haselden on 02/08/2024.
//

import XCTest
import Freelancer
import SwiftData

final class TaskTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testTaskPriorityComparision() {
        XCTAssertTrue(TaskPriority.high > TaskPriority.low)
        XCTAssertTrue(TaskPriority.medium > TaskPriority.low)
        XCTAssertTrue(TaskPriority.high > TaskPriority.medium)
        XCTAssertTrue(TaskPriority.high > TaskPriority.high)
        XCTAssertTrue(TaskPriority.medium > TaskPriority.medium)
        XCTAssertTrue(TaskPriority.low > TaskPriority.low)
    }

    func testTaskStatusComparision() {
        XCTAssertTrue(TaskStatus.pending > TaskStatus.cancelled)
        XCTAssertTrue(TaskStatus.done > TaskStatus.cancelled)
        XCTAssertTrue(TaskStatus.pending > TaskStatus.done)
        XCTAssertTrue(TaskStatus.pending > TaskStatus.pending)
        XCTAssertTrue(TaskStatus.done > TaskStatus.done)
        XCTAssertTrue(TaskStatus.cancelled > TaskStatus.cancelled)
    }
    
    func testTaskComparison() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Task.self, configurations: config)

        XCTAssertTrue(Task.sampleData[7] > Task.sampleData[6])
        XCTAssertTrue(Task.sampleData[7] > Task.sampleData[5])
        XCTAssertTrue(Task.sampleData[1] > Task.sampleData[0])
        XCTAssertTrue(Task.sampleData[2] > Task.sampleData[0])
        XCTAssertTrue(Task.sampleData[1] > Task.sampleData[2])

    }

}
