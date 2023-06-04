import 'package:chatgpt/screens/chat_screen.dart';
import 'package:chatgpt/services/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {

    super.initState();
    Future.delayed(const Duration(seconds: 3)).then((value) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx)=>const ChatScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
       mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Image.asset(AssetsManager.botImage,)),
          const SpinKitSpinningLines(
          color: Colors.white,
          size: 50.0,),
        ],
      )
    );
  }
}
