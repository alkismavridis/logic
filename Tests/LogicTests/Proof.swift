import XCTest
@testable import Logic

class ProofTest: XCTestCase {
    func testIniProof() {
		var th = LogicTheory()
		var pr:Proof = Proof(parent:th)

    }


    static var allTests = [
        ("testIniProof", testIniProof),
    ]
}
