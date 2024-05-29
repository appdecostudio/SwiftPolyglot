import XCTest

/// Asserts that an asynchronous expression do not throw an error.
/// (Intended to function as a drop-in asynchronous version of `XCTAssertNoThrow`.)
///
/// Example usage:
///
///     await assertNoThrowAsync(
///         try await sut.function()
///     ) { error in
///         XCTAssertEqual(error as? MyError, MyError.specificError)
///     }
///
/// - Parameters:
///   - expression: An asynchronous expression that can throw an error.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default is the file path of the test case where this function is being called.
///   - line: The line number where the failure occurs. The default is the line number where this function is being called.
public func XCTAssertNoThrowAsync(
    _ expression: @autoclosure () async throws -> some Any,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
    } catch {
        // expected no error to be thrown, but it was
        let customMessage = message()
        if customMessage.isEmpty {
            XCTFail("Asynchronous call did throw an error.", file: file, line: line)
        } else {
            XCTFail(customMessage, file: file, line: line)
        }
    }
}

/// Asserts that an asynchronous expression throws an error.
/// (Intended to function as a drop-in asynchronous version of `XCTAssertThrowsError`.)
///
/// Example usage:
///
///     await assertThrowsAsyncError(
///         try await sut.function()
///     ) { error in
///         XCTAssertEqual(error as? MyError, MyError.specificError)
///     }
///
/// - Parameters:
///   - expression: An asynchronous expression that can throw an error.
///   - message: An optional description of a failure.
///   - file: The file where the failure occurs. The default is the file path of the test case where this function is being called.
///   - line: The line number where the failure occurs. The default is the line number where this function is being called.
///   - errorHandler: An optional handler for errors that `expression` throws.
///
/// from: https://gitlab.com/-/snippets/2567566
public func XCTAssertThrowsErrorAsync(
    _ expression: @autoclosure () async throws -> some Any,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (_ error: any Error) -> Void = { _ in }
) async {
    do {
        _ = try await expression()
        // expected error to be thrown, but it was not
        let customMessage = message()
        if customMessage.isEmpty {
            XCTFail("Asynchronous call did not throw an error.", file: file, line: line)
        } else {
            XCTFail(customMessage, file: file, line: line)
        }
    } catch {
        errorHandler(error)
    }
}
