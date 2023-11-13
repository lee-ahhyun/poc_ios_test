import 'package:bloc/bloc.dart';

class NearbyModeBloc extends Cubit<bool> {
  NearbyModeBloc() : super(false);

  void onNearbyMode(bool value) => emit(value);
}
