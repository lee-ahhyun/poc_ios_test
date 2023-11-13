part of 'event_handler_bloc.dart';

@immutable
abstract class EventHandlerEvent extends Equatable {}

class EventHandlerInitialEvent extends EventHandlerEvent {
  @override
  List<Object?> get props => [];
}

class ConnectedEndpointDataEvent extends EventHandlerEvent {
  final dynamic value;

  ConnectedEndpointDataEvent(this.value);

  @override
  List<Object?> get props => [value];
}

/// todo
/// endpoint model 만들기
