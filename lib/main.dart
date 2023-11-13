import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ios_test/bloc/connection_bloc.dart';
import 'package:poc_ios_test/main_view.dart';
import 'bloc/endpoint_bloc.dart';
import 'bloc/event_handler_bloc/event_handler_bloc.dart';
import 'bloc/nearby_mode_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nearby ios demo ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<EventHandlerBloc>(
            create: (context) => EventHandlerBloc(),
          ),
          BlocProvider<ConnectionBloc>(
            create: (context) => ConnectionBloc(),
          ),
          BlocProvider<NearbyModeBloc>(
            create: (context) => NearbyModeBloc(),
          ),
          BlocProvider<EndpointBloc>(
            create: (context) => EndpointBloc(),
          ),
          //EndpointBloc
        ],
        child: MainView(),
      ),
    );
  }
}
///todo
/// restart app 생성
