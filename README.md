# SwiftySemaphore

[![Swift Package Manager](https://img.shields.io/badge/swift%20package%20manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
![Platforms](https://img.shields.io/static/v1?label=Platforms&message=iOS%20|%20macOS%20|%20tvOS%20|%20watchOS%20|%20Linux&color=brightgreen)
[![Build Status](https://travis-ci.org/GottaGetSwifty/SwiftySemaphore.svg?branch=master)](https://travis-ci.org/GottaGetSwifty/SwiftySemaphore)

## Easily add a Semaphore to Property Access

Rather than handling a semaphore manually, use a Property Wrapper to reduce boilerplate 

Turn this boilerplate

```swift
class YourType {
    private let semaphore = DispatchSemaphore(value: 1)
    private var _count: Int
    
    func setCount(_ count: Int) {
        defer {
            semaphore.signal()
        }
        semaphore.wait()
        _count = count
    }
    
    func getCount() -> Int {
        defer {
            semaphore.signal()
        }
        semaphore.wait()
        return _count
    }
}
```
Into a basic type with controlled access!

```swift
class YourType {

    @Semaphore
    private var count: Int
}
```
