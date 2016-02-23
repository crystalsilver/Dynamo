//
//  DynamoAppTests.swift
//  DynamoAppTests
//
//  Created by John Holdsworth on 20/06/2015.
//  Copyright (c) 2015 John Holdsworth. All rights reserved.
//

import Foundation
import DynamoApp
import XCTest

class DynamoAppTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func letWebKitDoItsThing() {
        NSRunLoop.mainRunLoop().runUntilDate( NSDate( timeIntervalSinceNow: 0.5 ) )
    }

    func bodyContains( reference: String ) -> Bool {
        if let html = evalJavaScript( "document.body.outerHTML" ) {
            return html.rangeOfString( reference ) != nil
        }
        return false

    }

    func testFormSubmission() {
        // This is an example of a functional test case.
        let problematicString = "Hello Test £ + = & % ? 今日は"
        let reference = problematicString.stringByReplacingOccurrencesOfString( "&", withString: "&amp;" )

        letWebKitDoItsThing()

        evalJavaScript( "document.location = '/example'" )

        letWebKitDoItsThing()

        evalJavaScript( "document.forms[0].title.value = '\(problematicString)'" )
        evalJavaScript( "document.forms[0].width.value = 10" )
        evalJavaScript( "document.forms[0].height.value = 10" )
        evalJavaScript( "document.forms[0].submit()" )

        letWebKitDoItsThing()

        XCTAssert( bodyContains( "<h2>\(reference)</h2>" ), "GET method submission" )

        evalJavaScript( "document.forms[0].x5y5.value = '\(problematicString)'" )
        evalJavaScript( "document.forms[0].submit()" )

        letWebKitDoItsThing()

        XCTAssert( bodyContains( "<td>\(reference)</td>" ), "POST method submission" )
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
