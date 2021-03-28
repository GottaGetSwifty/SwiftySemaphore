//
//  SwiftySemaphoreTests.swift
//
//
//  Created by PJ Fechner on 3/27/21.
//

@testable import SwiftySemaphore

import Foundation
import Quick
import Nimble

class SwiftySemaphoreTests: QuickSpec {
    override func spec() {
        describe("SwiftySemaphore") {
            it("ControlsAccess") {
                let mock = MockType.testInstance

                expect(mock.exclusiveAccessProperty) == "Oh Hai!"
                var canContinue = false
                DispatchQueue.global().async {
                    mock.mutate { (initial) -> String in
                        usleep(500)
                        return "There"
                    }
                }
                usleep(100)
                DispatchQueue.global().async {
                    expect(mock.exclusiveAccessProperty) == "There"
                    mock.exclusiveAccessProperty = "Done"
                    canContinue = true
                }
                expect(canContinue).toEventually(beTrue(), timeout: .seconds(5), pollInterval: .seconds(1))

            }
        }
    }
}

private class MockType {

    static var testInstance: MockType { MockType(exclusiveAccessProperty: "Oh Hai!") }

    @Semaphore
    var exclusiveAccessProperty: String

    init(exclusiveAccessProperty: String) {
        self.exclusiveAccessProperty = exclusiveAccessProperty
    }

    func mutate(action: @escaping (String) -> String) {
        _exclusiveAccessProperty.mutate(action)
    }
}
