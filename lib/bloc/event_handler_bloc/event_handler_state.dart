part of 'event_handler_bloc.dart';

@immutable
abstract class EventHandlerState extends Equatable {}

class EventHandlerInitial extends EventHandlerState {
  @override
  List<Object?> get props => [];
}

class EventHandlerLoaded extends EventHandlerState {
  final dynamic value;

  EventHandlerLoaded(this.value);

  @override
  List<Object?> get props => [value];
}
