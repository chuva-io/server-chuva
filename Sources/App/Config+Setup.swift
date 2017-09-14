import MongoProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(MongoProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(User.self)
        preparations.append(Form.self)
        preparations.append(Question.Text.self)
        preparations.append(Question.Integer.self)
        preparations.append(Question.Decimal.self)
        preparations.append(Question.SingleChoice<String>.self)
        preparations.append(Question.MultipleChoice<String>.self)
    }
}
