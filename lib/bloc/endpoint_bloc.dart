import 'package:bloc/bloc.dart';

class EndpointBloc extends Cubit<String> {
  EndpointBloc() : super("");

  void changeEndpointID(String value) => emit(value);
}
