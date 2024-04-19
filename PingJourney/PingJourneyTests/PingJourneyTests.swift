//
//  PingJourneyTests.swift
//  PingJourneyTests
//
//  Created by jey periyasamy on 4/15/24.
//

import XCTest
@testable import PingJourney

final class PingJourneyTests: XCTestCase {

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

}

//
//    func next(block: FlowContext.(Request) -> Request) {
//
//    }
//
   // let workFlow: WorkFlow
    
//    init(workFlow: WorkFlow) {
//        self.workFlow = workFlow
//    }
//
//    func next(block: FlowContext.(Request) -> Request) {
//        workflow.next.add(block)
//    }
    
    
    
    //// Define a generic protocol named Describable
    //public protocol Module: Hashable {
    ////    associatedtype T // Define an associated type
    //
    //    static func of(block: (Setup) -> ()) -> any Module
    //
    //}
    //
    //// Make KeyProtocol conform to Hashable by constraining ValueType to Hashable
    //extension Module /*where T: Hashable */{
    //    static func of(block: (Setup) -> ()) -> any Module {
    //
    //    }
    //}
