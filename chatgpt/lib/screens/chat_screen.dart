import 'dart:developer';

import 'package:chatgpt/constants/constants.dart';
import 'package:chatgpt/providers/models_provider.dart';
import 'package:chatgpt/services/api_services.dart';
import 'package:chatgpt/services/assets_manager.dart';
import 'package:chatgpt/services/services.dart';
import 'package:chatgpt/widgets/chat_widget.dart';
import 'package:chatgpt/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../models/chat_model.dart';
import '../providers/chat_provider.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  static const String routeName= "/home";

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  late TextEditingController  textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode ;

  @override
  void initState() {
    _listScrollController= ScrollController();
   textEditingController= TextEditingController();
   focusNode= FocusNode();
    super.initState();
  }
  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }
  // List<ChatModel> chatList =[];
  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 2,
        elevation: 10,
        leading:Padding(
          padding: const EdgeInsets.all(8.0),
          child:  Image.asset(AssetsManager.openAiLogo , fit: BoxFit.cover,),
        ),
        title: const Text("Ask AI"),
        actions: [
          IconButton(
            onPressed: () async {
              await Services.showModelSheet(
                  context: context);
            },
            icon: const Icon(Icons.more_vert_rounded),
            color: Colors.white,)
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                controller: _listScrollController,
                itemCount: chatProvider.getChatList.length,
                  itemBuilder: (context, index)
              {return ChatWidget(
                msg:  chatProvider.getChatList[index].msg,//chatList[index].msg,
                chatIndex: chatProvider.getChatList[index].chatIndex,
                shouldAnimate:
                chatProvider.getChatList.length - 1 == index,


              );
    }),
            ),
           if(_isTyping)...[
             const SizedBox(height: 5,child: ColoredBox(color: Colors.transparent),),
             const SpinKitThreeBounce(
               color: Colors.white,size: 18,)
             ,
             const SizedBox(height: 5,child: ColoredBox(color: Colors.transparent),),
           ],

            Material(
              color: Color(0xFF282A3A) ,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                          focusNode: focusNode,
                          style:const TextStyle(
                              color: Colors.white
                          ) ,
                          controller: textEditingController,
                          onSubmitted: (value) async {
                            await sendMessageFCT(
                                modelsProvider: modelsProvider,
                                chatProvider: chatProvider);
                          },
                          decoration: const InputDecoration.collapsed(
                              hintText: "How can i help you",
                              hintStyle: TextStyle(
                                  color: Colors.grey
                              )
                          ),
                        )),
                    IconButton(
                      onPressed: ()async{
                        await sendMessageFCT(
                            modelsProvider: modelsProvider,
                            chatProvider: chatProvider);
                      },
                      icon: const Icon(
                          Icons.send, color: Colors.white,),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      )
    );
  }

  void scrollListToEnd(){
    _listScrollController.animateTo(
      _listScrollController.position.maxScrollExtent
    , duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
        required ChatProvider chatProvider})async{
    if(_isTyping){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const TextWidget(label: "You can't send a multiple message at a time"),
            backgroundColor: Colors.red[500],));
      return;
    }
    if(textEditingController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
            content: const TextWidget(
                label: 'Please type a message'),
            backgroundColor: Colors.red[500],));
      return;
    }
    try{
      String msg = textEditingController.text;
      setState(() {
        _isTyping= true;
        // chatList.add(ChatModel(msg: textEditingController.text, chatIndex: 0));
        chatProvider.addUserMessage(
            msg: msg);
        textEditingController.clear();
        focusNode.unfocus();
      });
     await chatProvider.sendMessageAndGetAnswers(
         msg: msg,
         chosenModelId: modelsProvider.getCurrentModel);
     setState(() {});
    }catch(error){
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: TextWidget(label: error.toString()),
            backgroundColor: Colors.red,));
    }finally{
      setState(() {
        scrollListToEnd();
        _isTyping= false;
      });
    }
  }

}
