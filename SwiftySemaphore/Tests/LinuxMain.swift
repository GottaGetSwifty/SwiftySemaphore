import XCTest

import Quick

@testable import SwiftySemaphoreTests

let allTestClasses = [
    SwiftySempahoreTests.self,
]
Quick.QCKMain(allTestClasses)
