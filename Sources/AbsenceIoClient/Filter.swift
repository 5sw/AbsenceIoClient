public enum Comparison<Value: Encodable> {
    case equals(Value)
    case `in`(Value)
    case notIn(Value)
    case greater(Value)
    case greaterEquals(Value)
    case less(Value)
    case lessEquals(Value)
}

extension Comparison: Encodable {
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .equals(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)

        case .in(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .in)

        case .notIn(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .notIn)

        case .greater(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .greater)

        case .greaterEquals(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .greaterEquals)

        case .less(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .less)

        case .lessEquals(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .lessEquals)
        }
    }

    enum CodingKeys: String, CodingKey {
        case `in` = "$in"
        case notIn = "$nin"
        case greater = "$gt"
        case greaterEquals = "$gte"
        case less = "$lt"
        case lessEquals = "$lte"
    }
}

public struct FilterKey: CodingKey {
    public var stringValue: String

    init(_ string: String) {
        self.init(stringValue: string)
    }

    public init(stringValue: String) {
        self.stringValue = stringValue
    }

    public var intValue: Int? { nil }

    public init?(intValue: Int) {
        return nil
    }

    static let orKey = Self("$or")
}

extension FilterKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

public protocol AnyFilter: Encodable {
    func encode(container: inout KeyedEncodingContainer<FilterKey>) throws
}

public extension AnyFilter {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FilterKey.self)
        try encode(container: &container)
    }
}

public struct Filter<Value: Encodable>: AnyFilter {
    var key: FilterKey
    var comparison: Comparison<Value>

    public func encode(container: inout KeyedEncodingContainer<FilterKey>) throws {
        try container.encode(comparison, forKey: key)
    }
}

public struct AndFilter: AnyFilter {
    var children: [AnyFilter]

    public func encode(container: inout KeyedEncodingContainer<FilterKey>) throws {
        for child in children {
            try child.encode(container: &container)
        }
    }
}

public struct OrFilter: AnyFilter {
    var children: [AnyFilter]

    public func encode(container: inout KeyedEncodingContainer<FilterKey>) throws {
        switch children.count {
        case 0:
            break

        case 1:
            try children[0].encode(container: &container)

        default:
            var childContainer = container.nestedUnkeyedContainer(forKey: .orKey)
            try encodeChildren(container: &childContainer)
        }
    }

    func encodeChildren(container: inout UnkeyedEncodingContainer) throws {
        for child in children {
            if let orChild = child as? OrFilter {
                try orChild.encodeChildren(container: &container)
            } else {

                var childContainer = container.nestedContainer(keyedBy: FilterKey.self)
                try child.encode(container: &childContainer)
            }
        }
    }
}

public extension AnyFilter where Self == OrFilter {
    static func anyOf(_ children: AnyFilter...) -> OrFilter {
        OrFilter(children: children)
    }
}

public extension AnyFilter where Self == AndFilter {
    static func allOf(_ children: AnyFilter...) -> AndFilter {
        AndFilter(children: children)
    }
}

public func ==<T>(lhs: FilterKey, rhs: T) -> Filter<T> {
    return Filter(key: lhs, comparison: .equals(rhs))
}

public func <=<T>(lhs: FilterKey, rhs: T) -> Filter<T> {
    return Filter(key: lhs, comparison: .lessEquals(rhs))
}

public func <<T>(lhs: FilterKey, rhs: T) -> Filter<T> {
    return Filter(key: lhs, comparison: .less(rhs))
}

public func >=<T>(lhs: FilterKey, rhs: T) -> Filter<T> {
    return Filter(key: lhs, comparison: .greaterEquals(rhs))
}

public func ><T>(lhs: FilterKey, rhs: T) -> Filter<T> {
    return Filter(key: lhs, comparison: .greater(rhs))
}

public extension FilterKey {
    func `in`<T>(_ values: T) -> Filter<T> where T: Sequence {
        return Filter(key: self, comparison: .in(values))
    }

    func `notIn`<T>(_ values: T) -> Filter<T> where T: Sequence {
        return Filter(key: self, comparison: .notIn(values))
    }
}

public struct Relation: AnyFilter {
    var key: String
    var entity: String
    var id: String = "_id"
    var filter: AnyFilter

    public init(key: String, entity: String, id: String = "_id", filter: AnyFilter) {
        self.key = key
        self.entity = entity
        self.id = id
        self.filter = filter
    }

    public func encode(container: inout KeyedEncodingContainer<FilterKey>) throws {
        let key = FilterKey("\(key):\(entity).\(id)")
        var child = container.nestedContainer(keyedBy: FilterKey.self, forKey: key)
        try filter.encode(container: &child)
    }
}
