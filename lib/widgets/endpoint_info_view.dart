import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EndPointInfoView extends StatelessWidget {
  const EndPointInfoView({super.key, required this.endpointID});
  final String endpointID;


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 50,
      decoration: BoxDecoration(border: Border.all(width: 1,color: Colors.black)),
      child: Center(child: Text("endpointID : [ $endpointID ] "),),
    );
  }
}
