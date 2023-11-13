import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ios_test/bloc/connection_bloc.dart';
import 'package:poc_ios_test/widgets/endpoint_info_view.dart';
import 'package:poc_ios_test/widgets/nearby_mode_view.dart';
import 'bloc/endpoint_bloc.dart';
import 'bloc/event_handler_bloc/event_handler_bloc.dart';
import 'bloc/nearby_mode_bloc.dart';
import 'platform_channel_service.dart';

class MainView extends StatelessWidget {
  MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final nearbyModeBloc = BlocProvider.of<NearbyModeBloc>(context);
    final connectionBloc = BlocProvider.of<ConnectionBloc>(context);
    final endpointBloc = BlocProvider.of<EndpointBloc>(context);

    Widget nearbyModeView() {

      Future<void> getNearbyOnOffState(
          {required bool isEnabled, required NearByMode mode }) async {
        connectionBloc.changeState(ConnectionStatus.loading);
        nearbyModeBloc.onNearbyMode(true);
        await PlatformChannelService.getMethodChannelValue(
            method: 'getNearbyOnOffState',
            argument: {
              'mode': mode.name,
              "isEnabled": isEnabled
            });
      }

      return BlocBuilder<NearbyModeBloc, bool>(
        builder: (context, state) {

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NearByModeWidget(
                mode: NearByMode.sender,
                isEnabled: state,
                onTap: () async =>
                    getNearbyOnOffState(
                        isEnabled: state, mode: NearByMode.sender),
              ),
              NearByModeWidget(
                mode: NearByMode.receiver,
                isEnabled: state,
                onTap: () async =>
                    getNearbyOnOffState(
                        isEnabled: state, mode: NearByMode.receiver),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: (){},
                  child: Container(
                    width: 100,
                    height: 50,
                    decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.5)),
                    child: const Center(child: Text("context 초기화",style: TextStyle(color: Colors.black),)),

                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    Widget connectionView() {
      return BlocBuilder<ConnectionBloc, ConnectionStatus>(
        builder: (BuildContext context, state) {
          print("Connection state  => $state");
          Widget result;
          switch (state) {
            case ConnectionStatus.init:
              result = Container(
                //    color: Colors.blue,
                width: 100,
                height: 100,
              );
            case ConnectionStatus.loading:
              result = Container(
                // color: Colors.pinkAccent,
                  width: 50,
                  height: 50,
                  child: const CircularProgressIndicator());
            case ConnectionStatus.success:
              result = BlocBuilder<EndpointBloc, String>(
                  builder: (context, endState) {
                    return Column(
                      children: [
                        EndPointInfoView(endpointID: endState),
                        // 이벤트 핸들러 통해서 받기
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(onPressed: () async {
                              //'shouldAccept',{'endpointID'
                              await PlatformChannelService
                                  .getMethodChannelValue(
                                  method: 'shouldAccept',
                                  argument: {
                                    'endpointID': endState, // 이벤트 핸들러 name 보내주기
                                  });
                              // MODE 체크
                              connectionBloc.changeState(
                                  ConnectionStatus.sending);
                            }, child: const Text("accept")),
                            TextButton(onPressed: () async {
                              connectionBloc.changeState(ConnectionStatus.init);
                              nearbyModeBloc.onNearbyMode(false);
                            }, child: const Text("reject")),
                          ],
                        ),
                      ],
                    );
                  }
              );
            case ConnectionStatus.sending:
              result = BlocBuilder<EndpointBloc, String>(
                  builder: (context, endState) {
                    return TextButton(onPressed: () async {
                      final value = await PlatformChannelService
                          .getMethodChannelValue(
                          method: 'sendBytes',
                          argument: {
                            'endpointID': endState, // 이벤트 핸들러 name 보내주기
                          });
                          print("value ===> $value");
                   //   if(value){
                        connectionBloc.changeState(ConnectionStatus.completed);
                     // }
                    }, child: const Text("send data"));
                  }
              );
            case ConnectionStatus.completed:
              result = TextButton(onPressed: (){
                connectionBloc.changeState(ConnectionStatus.success);
                nearbyModeBloc.onNearbyMode(false);
              }, child: Text("데이터 보내기 성공 !! 처음으로"));
            case ConnectionStatus.receiving:
              result = Text('받는중 ');
            case ConnectionStatus.failure:
              result = const Text("fail");
            default:
              result = Container(
                color: Colors.deepPurple,
                width: 100,
                height: 100,
              );
          }

          return result;
        },
      );
    }

    return BlocBuilder<EventHandlerBloc, EventHandlerState>(
      builder: (context, eventHandlerState) {
        if (eventHandlerState is EventHandlerLoaded) {
          dynamic map = eventHandlerState.value;
          connectionBloc.changeState(ConnectionStatus.success);
          endpointBloc.changeEndpointID(map["endpointID"]);
          print("eventHandlerState.value  => ${eventHandlerState.value}");

          /// todo 위젯 다시 배치 하기
        }
        print("eventstate => $eventHandlerState");

        /// todo
        ///  이벤트 핸들러 파일 보내는거 성공시 팝업 띄워주기
        ///  다시 초기화 시켜주기

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme
                .of(context)
                .colorScheme
                .inversePrimary,
            title: const Text(''),
          ),
          body: Center(
            child: Column(
              children: [
                nearbyModeView(),
                connectionView(),
              ],
            ),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      },
    );
  }
}
