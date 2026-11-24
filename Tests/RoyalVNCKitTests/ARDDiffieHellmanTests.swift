import XCTest
@testable import RoyalVNCKit

final class ARDDiffieHellmanTests: XCTestCase {
	/// Keys serialize without leading zero bytes, which is about 1 in 256 per key.
	/// The protocol wants full-width keys, so the agreement must pad them instead of failing.
	func testKeysAreAlwaysFullWidth() throws {
		let keyLength = 16
		let prime = Data(repeating: 0xFF, count: keyLength - 1) + Data([0xFD]) // odd, 128-bit, small so the test is fast
		let generator = Data([2])
		let peerKey = Data([0x01]) + Data(repeating: 0xAB, count: keyLength - 1)

		for _ in 0..<3000 {
			let agreement = try XCTUnwrap(VNCProtocol.ARDAuthentication.DiffieHellmanKeyAgreement(
				prime: prime, generator: generator, peerKey: peerKey, keyLength: keyLength))

			XCTAssertEqual(agreement.publicKey.count, keyLength)
			XCTAssertEqual(agreement.privateKey.count, keyLength)
			XCTAssertEqual(agreement.secretKey.count, keyLength)
		}
	}
}
