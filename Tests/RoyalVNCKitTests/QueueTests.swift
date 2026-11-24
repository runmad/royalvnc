import XCTest
@testable import RoyalVNCKit

final class QueueTests: XCTestCase {
	/// The send loop dequeues on one thread while the app enqueues on another.
	func testConcurrentEnqueueAndDequeueLosesNothing() {
		var queue = Queue<Int>() // var: compiles against the old struct too
		let perProducer = 20_000
		let producers = 4
		let dequeued = NSLock()
		var received = 0

		let group = DispatchGroup()
		for _ in 0..<producers {
			DispatchQueue.global().async(group: group) {
				for i in 0..<perProducer { queue.enqueue(i) }
			}
		}
		DispatchQueue.global().async(group: group) {
			var mine = 0
			while mine < perProducer * producers {
				if queue.dequeue() != nil { mine += 1 }
			}
			dequeued.lock(); received = mine; dequeued.unlock()
		}

		XCTAssertEqual(group.wait(timeout: .now() + 60), .success)
		XCTAssertEqual(received, perProducer * producers)
		XCTAssertTrue(queue.isEmpty)
	}
}
