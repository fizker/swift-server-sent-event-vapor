import Vapor

extension BodyStreamWriter {
	func safeWrite(_ result: BodyStreamResult) -> EventLoopFuture<Void> {
		let promise = eventLoop.makePromise(of: Void.self)
		promise.succeed(())
		return promise.futureResult.flatMap {
			write(result)
		}
	}

	func write(_ result: BodyStreamResult) async throws {
		try await safeWrite(result).get()
	}

	func write(line: String) async throws {
		try await write(.buffer(.init(string: line + "\n")))
	}
}
