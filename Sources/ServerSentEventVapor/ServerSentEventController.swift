import Foundation
import ServerSentEventModels
import Vapor

/// A controller that maintains the connections and can close or send messages.
public class ServerSentEventController {
	public typealias Stream = AsyncStream<MessageEvent>

	private var streams: [UUID: Stream.Continuation] = [:]

	/// Creates a new ``ServerSentEventController``.
	public init() {
	}

	/// Creates a new ``ServerSentEventResponse`` and returns it. The `Response` can be returned from a route.
	/// - parameter id: The `UUID` that represents the connection.
	/// - parameter onClose: A function that is executed when the connection is closed by the remote end.
	public func createResponse(id: UUID, onClose: @escaping () -> Void = {}) -> ServerSentEventResponse {
		return ServerSentEventResponse(id: id, stream: createStream(id: id)) { [weak self] in
			self?.streams.removeValue(forKey: id)
			onClose()
		}
	}

	func createStream(id: UUID) -> Stream {
		return AsyncStream {
			streams[id] = $0
		}
	}

	/// Sends the given message to all current connections.
	/// - parameter message: The message to send.
	public func emit(_ message: MessageEvent) {
		for (_, continuation) in streams {
			continuation.yield(message)
		}
	}

	/// Sends the given message to the connection with the given `UUID`.
	/// - parameter message: The message to send.
	/// - parameter id: The `UUID` of the connection that should receive the message.
	public func emit(_ message: MessageEvent, to id: UUID) {
		streams[id]?.yield(message)
	}

	/// Sends the given message to all current connections except the one matching the given `UUID`.
	/// - parameter message: The message to send.
	/// - parameter id: The `UUID` of the connection that should _not_ receive the message.
	public func emit(_ message: MessageEvent, toAllExcept id: UUID) {
		for (x, continuation) in streams where x != id {
			continuation.yield(message)
		}
	}

	/// Closes all currently open connections.
	public func closeAll() {
		for (_, continuation) in streams {
			continuation.finish()
		}
		streams = [:]
	}

	/// Closes the connection for the given `UUID`. If there are no matches, this does nothing.
	/// - parameter id: The `UUID` of the connection to close.
	public func close(id: UUID) {
		let continuation = streams.removeValue(forKey: id)
		continuation?.finish()
	}
}
