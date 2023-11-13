import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum NearByMode { sender, receiver }

class NearByModeWidget extends StatelessWidget {
  const NearByModeWidget({super.key, required this.mode, required this.isEnabled, this.onTap});

  final NearByMode mode;
  final bool isEnabled;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {

    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 100,
          height: 50,
          decoration: BoxDecoration(
              color: isEnabled
                  ? Colors.black12
                  : Colors.pinkAccent.withOpacity(0.5)),
          child: Center(child: Text(mode.name,style: const TextStyle(color: Colors.black),)),

        ),
      ),);
  }
}
