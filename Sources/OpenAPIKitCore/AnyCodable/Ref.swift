import Foundation

@propertyWrapper
struct Ref<Value> {

	let get: () -> Value
	let set: (Value) -> Void

	var wrappedValue: Value {
		get { get() }
		nonmutating set { set(newValue) }
	}

	var projectedValue: Ref {
		get { self }
		set { self = newValue }
	}
}

extension Ref {

	static func constant(_ value: Value) -> Ref {
        self.init(
            get: {
                value
            }, set: { _ in
            }
        )
	}

	init<T>(_ value: T, _ keyPath: ReferenceWritableKeyPath<T, Value>) {
        self.init(
            get: {
                value[keyPath: keyPath]
            }, set: { newValue in
                value[keyPath: keyPath] = newValue
            }
        )
	}
}
