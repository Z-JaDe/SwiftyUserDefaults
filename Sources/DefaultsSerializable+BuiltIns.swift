//
// SwiftyUserDefaults
//
// Copyright (c) 2015-2018 Radosław Pietruszewski, Łukasz Mróz
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

extension String: DefaultsSerializable, DefaultsDefaultArrayValueType, DefaultsDefaultValueType {

    public static var defaultValue: String = ""
    public static var defaultArrayValue: [String] = []

    public static func get(key: String, userDefaults: UserDefaults) -> String? {
        return userDefaults.string(forKey: key)
    }

    public static func save(key: String, value: String?, userDefaults: UserDefaults) {
        userDefaults.set(value, forKey: key)
    }
}

extension Int: DefaultsSerializable, DefaultsDefaultArrayValueType, DefaultsDefaultValueType {

    public static var defaultValue: Int = 0
    public static var defaultArrayValue: [Int] = []

    public static func get(key: String, userDefaults: UserDefaults) -> Int? {
        return userDefaults.number(forKey: key)?.intValue
    }

    public static func save(key: String, value: Int?, userDefaults: UserDefaults) {
        userDefaults.set(value, forKey: key)
    }
}

extension Double: DefaultsSerializable, DefaultsDefaultArrayValueType, DefaultsDefaultValueType {

    public static var defaultValue: Double = 0.0
    public static var defaultArrayValue: [Double] = []

    public static func get(key: String, userDefaults: UserDefaults) -> Double? {
        return userDefaults.number(forKey: key)?.doubleValue
    }

    public static func save(key: String, value: Double?, userDefaults: UserDefaults) {
        userDefaults.set(value, forKey: key)
    }
}

extension Bool: DefaultsSerializable, DefaultsDefaultArrayValueType, DefaultsDefaultValueType {

    public static var defaultValue: Bool = false
    public static var defaultArrayValue: [Bool] = []

    public static func get(key: String, userDefaults: UserDefaults) -> Bool? {
        // @warning we use number(forKey:) instead of bool(forKey:), because
        // bool(forKey:) will always return value, even if it's not set
        // and it does a little bit of magic under the hood as well
        // e.g. transforming strings like "YES" or "true" to true
        return userDefaults.number(forKey: key)?.boolValue
    }

    public static func save(key: String, value: Bool?, userDefaults: UserDefaults) {
        userDefaults.set(value, forKey: key)
    }
}

extension Data: DefaultsSerializable, DefaultsDefaultArrayValueType, DefaultsDefaultValueType {

    public static var defaultValue: Data = Data()
    public static var defaultArrayValue: [Data] = []

    public static func get(key: String, userDefaults: UserDefaults) -> Data? {
        return userDefaults.data(forKey: key)
    }

    public static func save(key: String, value: Data?, userDefaults: UserDefaults) {
        userDefaults.set(value, forKey: key)
    }
}

extension Date: DefaultsSerializable {

    public static func get(key: String, userDefaults: UserDefaults) -> Date? {
        return userDefaults.object(forKey: key) as? Date
    }

    public static func save(key: String, value: Date?, userDefaults: UserDefaults) {
        userDefaults.set(value, forKey: key)
    }
}
extension URL: DefaultsSerializable {

    public static func get(key: String, userDefaults: UserDefaults) -> URL? {
        return userDefaults.url(forKey: key)
    }

    public static func save(key: String, value: URL?, userDefaults: UserDefaults) {
        userDefaults.set(value, forKey: key)
    }
}

extension Array: DefaultsSerializable where Element: DefaultsSerializable {

    public static func get(key: String, userDefaults: UserDefaults) -> Array<Element>? {
        // URL/NSCoding are special for arrays, thus we use unarchiving instead of classic `array`
        if Element.self is NSCoding.Type || Element.self is URL.Type {
            return userDefaults.data(forKey: key).flatMap(NSKeyedUnarchiver.unarchiveObject) as? [Element]
        } else {
            return userDefaults.array(forKey: key) as? [Element]
        }
    }

    public static func save(key: String, value: Array<Element>?, userDefaults: UserDefaults) {
        guard let value = value else {
            userDefaults.removeObject(forKey: key)
            return
        }

        // URL/NSCoding are special for arrays, thus we use archiving instead of classic `array`
        if Element.self is NSCoding.Type || Element.self is URL.Type {
            userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: value), forKey: key)
        } else {
            userDefaults.set(value, forKey: key)
        }
    }
}

extension Decodable {

    public static func decodable(key: String, userDefaults: UserDefaults) -> Self? {
        return userDefaults.decodable(forKey: key) as Self?
    }
}

extension Encodable {

    public static func saveEncodable(key: String, value: Self?, userDefaults: UserDefaults) {
        guard let value = value else {
            userDefaults.removeObject(forKey: key)
            return
        }

        userDefaults.set(encodable: value, forKey: key)
    }
}

extension DefaultsStoreable where Self: NSCoding {

    public static func save(key: String, value: Self?, userDefaults: UserDefaults) {
        userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: value), forKey: key)
    }
}

extension DefaultsGettable where Self: NSCoding {

    public static func get(key: String, userDefaults: UserDefaults) -> Self? {
        return userDefaults.data(forKey: key).flatMap(NSKeyedUnarchiver.unarchiveObject) as? Self
    }
}
