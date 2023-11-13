import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../platform_channel_service.dart';

part 'event_handler_event.dart';

part 'event_handler_state.dart';

class EventHandlerBloc extends Bloc<EventHandlerEvent, EventHandlerState> {
  EventHandlerBloc() : super(EventHandlerInitial()) {
    eventChannelListener();
    on<EventHandlerEvent>(getState);
  }

  Future<void> getState(
    EventHandlerEvent event,
    Emitter<EventHandlerState> emit,
  ) async {
    emit(EventHandlerInitial());
    if (event is ConnectedEndpointDataEvent) {
      emit(EventHandlerLoaded(event.value));
    }
  }

  void eventChannelListener() {
    PlatformChannelService.eventChannel.receiveBroadcastStream().listen((d) {
      print("d ==> $d");
      if (d == null) {
        return;
      }
      _onRedirected(d);
    });
  }

  _onRedirected(dynamic value) {
    add(ConnectedEndpointDataEvent(value));
  }

  void dispose() {}
}
