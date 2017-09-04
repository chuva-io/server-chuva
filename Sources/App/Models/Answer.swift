import FluentProvider

struct Answer {

    final class Integer: Model, TypedAnswer {
        var value: Int?

        init(value: Int?) {
            self.value = value
        }
        
        let storage = Storage()
        
        init(row: Row) throws {
            value = try row.get("value")
        }
        
        func makeRow() throws -> Row {
            var row = Row()
            try row.set("value", value)
            return row
        }
        
    }

    final class Decimal: Model, TypedAnswer {
        var value: Double?

        init(value: Double?) {
            self.value = value
        }
        
        let storage = Storage()
        
        init(row: Row) throws {
            value = try row.get("value")
        }
        
        func makeRow() throws -> Row {
            var row = Row()
            try row.set("value", value)
            return row
        }
    }

    final class Text: Model, TypedAnswer {
        var value: String?

        init(value: String?) {
            self.value = value
        }
        
        let storage = Storage()
        
        init(row: Row) throws {
            value = try row.get("value")
        }
        
        func makeRow() throws -> Row {
            var row = Row()
            try row.set("value", value)
            return row
        }
    }

    final class SingleChoice<T: Hashable>: Model, TypedAnswer {
        var value: T?

        init(value: T?) {
            self.value = value
        }
        
        let storage = Storage()
        
        init(row: Row) throws {
            value = try row.get("value")
        }
        
        func makeRow() throws -> Row {
            var row = Row()
            try row.set("value", value)
            return row
        }
    }

    final class MultipleChoice<T: Hashable>: Model, TypedAnswer {
        var value: Set<T>?

        init(value: Set<T>?) {
            self.value = value
        }
        
        let storage = Storage()
        
        init(row: Row) throws {
            value = try row.get("value")
        }
        
        func makeRow() throws -> Row {
            var row = Row()
            try row.set("value", value)
            return row
        }
    }

}
