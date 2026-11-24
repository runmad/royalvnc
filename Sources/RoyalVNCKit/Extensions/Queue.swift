import Foundation

/// Thread-safe: the app enqueues from its own thread while the send loop dequeues on another.
final class Queue<T>: @unchecked Sendable {
	private let lock = NSLock()
	private var list = [T]()

	func enqueue(_ element: T) {
		lock.lock(); defer { lock.unlock() }

		list.append(element)
	}

	func dequeue() -> T? {
		lock.lock(); defer { lock.unlock() }

		guard !list.isEmpty else { return nil }

		return list.removeFirst()
	}

	func clear() {
		lock.lock(); defer { lock.unlock() }

		list.removeAll()
	}

	func peek() -> T? {
		lock.lock(); defer { lock.unlock() }

		return list.first
	}

	var isEmpty: Bool {
		lock.lock(); defer { lock.unlock() }

		return list.isEmpty
	}
}
