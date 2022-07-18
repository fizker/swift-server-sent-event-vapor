import Foundation
import ServerSentEventModels
import Vapor

public class ServerSentEventController {
	public typealias Stream = AsyncStream<MessageEvent>

	private var streams: [UUID: Stream.Continuation] = [:]

	public init() {
	}

	public func createResponse(id: UUID, onClose: @escaping () -> Void) -> ServerSentEventResponse {
		return ServerSentEventResponse(stream: createStream(id: id), onClose: onClose)
	}

	func createStream(id: UUID) -> Stream {
		return AsyncStream {
			streams[id] = $0
		}
	}

	public func emit(_ message: MessageEvent) {
		for (_, continuation) in streams {
			continuation.yield(message)
		}
	}

	public func close() {
		for (_, continuation) in streams {
			continuation.finish()
		}
		streams = [:]
	}

	public func close(id: UUID) {
		let continuation = streams.removeValue(forKey: id)
		continuation?.finish()
	}
}
