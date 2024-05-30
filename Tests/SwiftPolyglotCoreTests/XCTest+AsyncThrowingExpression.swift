import XCTest

/// Asserts that an asynchronous expression do not throw an error.
/// (Intended to function as a drop-in asynchronous version of `XCTAssertNoThrow`.)
///
/// Example usage:
///
///     await assertNoThrowAsync(sut.function)
///
/// - Parameters:
///   - expression: An asynchronous expression that can throw an error.
///   - failureMessage: An optional description of a failure.
///   - file: The file where the failure occurs. The default is the file path of the test case where this function is being called.
///   - line: The line number where the failure occurs. The default is the line number where this function is being called.
public func XCTAssertNoThrowAsync(
    _ expression: () async throws -> some Any,
    failureMessage: String = "Asynchronous call did throw an error.",
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
    } catch {
        XCTFail(failureMessage, file: file, line: line)
    }
}

/// Asserts that an asynchronous expression throws an error.
/// (Intended to function as a drop-in asynchronous version of `XCTAssertThrowsError`.)
///
/// Example usage:
///
///     await assertThrowsAsyncError(sut.function, MyError.specificError)
///
/// - Parameters:
///   - expression: An asynchronous expression that can throw an error.
///   - errorThrown: The error type that should be thrown.
///   - failureMessage: An optional description of a failure.
///   - file: The file where the failure occurs. The default is the file path of the test case where this function is being called.
///   - line: The line number where the failure occurs. The default is the line number where this function is being called.
///
/// from: https://arturgruchala.com/testing-async-await-exceptions/
func XCTAssertThrowsErrorAsync<E>(
    _ expression: () async throws -> some Any,
    _ errorThrown: E,
    failureMessage: String = "Asynchronous call did not throw an error.",
    file: StaticString = #filePath,
    line: UInt = #line
) async where E: Equatable, E: Error {
    do {
        _ = try await expression()
        XCTFail(failureMessage, file: file, line: line)
    } catch {
        XCTAssertEqual(
            error as? E,
            errorThrown,
            "Asynchronous call did not throw the given error \"\(errorThrown)\".",
            file: file,
            line: line
        )
    }
}
