import 'package:bloc/bloc.dart';

enum ConnectionStatus {
  init,
  loading,
  success,
  sending,
  receiving,
  failure,
  completed
}

class ConnectionBloc extends Cubit<ConnectionStatus> {
  ConnectionBloc() : super(ConnectionStatus.init);

  changeState(ConnectionStatus nearbyConnectionStatus) {
    emit(nearbyConnectionStatus);
  }
}
