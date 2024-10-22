import Vapor
import ServerSentEventModels

/// A HTTP Response that streams Server-Sent events.
public class ServerSentEventResponse: AsyncResponseEncodable {
	/// The `UUID` representing this connection.
	public let id: UUID

	let headers: HTTPHeaders = HTTPHeaders([
		( "content-type", serverSentEventMIMEType ),
	])
	private let stream: AsyncStream<MessageEvent>
	private var onClose: () -> Void

	init(id: UUID, stream: AsyncStream<MessageEvent>, onClose: @escaping () -> Void) {
		self.id = id
		self.stream = stream
		self.onClose = onClose
	}

	public func encodeResponse(for request: Request) async throws -> Response {
		return Response(
			status: .ok,
			headers: headers,
			body: .init(stream: write(_:))
		)
	}

	private func write(_ writer: BodyStreamWriter) {
		Task {
			do {
				try await writer.write(line: ":ok")
				try await writer.write(line: "")

				for await data in self.stream {
					for line in data.asLines {
						try await writer.write(line: line.asString)
					}
					try await writer.write(line: "")
				}
			} catch {
				// If something goes wrong with the writer, we close down
			}

			try? await writer.write(.end)
			onClose()
		}
	}
}
