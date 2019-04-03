//
//  TonnetzTests.swift
//  TonnetzTests
//
//  Created by Michael Burks on 3/30/19.
//  Copyright © 2019 Michael Burks. All rights reserved.
//

import XCTest
@testable import Tonnetz

class TonnetzTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMidiBank() {
      let bank = MIDIBank()
      XCTAssertEqual(bank[10], .off)

      bank[10] = .on

      XCTAssertEqual(bank.count(note: 22), 1)

      bank[22] = .on

      XCTAssertEqual(bank[22], .on)
      XCTAssertEqual(bank.count(note: 22), 1)

      bank[10] = .off
      XCTAssertEqual(bank[10], .off)
      XCTAssertEqual(bank[22], .on)
      XCTAssertEqual(bank.count(note: 22), 1)


      bank[22] = .off
      XCTAssertEqual(bank[22], .off)
      XCTAssertEqual(bank.count(note: 22), 0)

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
