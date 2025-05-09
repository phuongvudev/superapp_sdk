/// Represents an event used for communication within the app.
///
/// Each event has a `type` to identify its purpose and associated `data`
/// that contains the event's payload.
class Event {
  /// The type of the event, used to identify its purpose.
  final String type;

  /// The payload of the event, which can be any data type.
  final dynamic data;

  /// Creates a new instance of `Event`.
  ///
  /// [type] - The type of the event.
  /// [data] - The payload of the event.
  Event(this.type, this.data);
}