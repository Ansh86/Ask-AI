import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chatgpt/models/chat_model.dart';
import 'package:http/http.dart' as http;
import '../constants/api_consts.dart';
import '../models/models_model.dart';


class ApiServices {
  static Future<List<ModelsModel>> getModels() async{
    try{
      var response = await http.get(
        Uri.parse("$BASE_URL/models"),
        headers: {
          'Authorization': 'Bearer $API_KEY'
        },
      );

      Map jsonResponse = jsonDecode(response.body);

      if(jsonResponse['error']!=null){
        // log("jsonResponse['error] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      List temp=[];
      for(var value in jsonResponse["data"]){
       temp.add(value);
       // log("temp ${value["id"]}");
      }

      // log("jsonResponse $jsonResponse");
      return ModelsModel.modelsFromSnapshot(temp);
    }catch(error){
      log("error $error");
      rethrow;
    }
  }

  // send message using chatGPT API

  static Future<List<ChatModel>> sendMessageGPT(
      {required String message, required String modelId}) async {
    try {
      log("modelId $modelId");
      var response = await http.post(
        Uri.parse("$BASE_URL/chat/completions"),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "model": modelId,
            "messages": [
              {
                "role": "user",
                "content": message,
              }
            ]
          },
        ),
      );

      // Map jsonResponse = jsonDecode(response.body);
      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      List<ChatModel> chatList = [];
      if (jsonResponse["choices"].length > 0) {
        // log("jsonResponse[choices]text ${jsonResponse["choices"][0]["text"]}");
        chatList = List.generate(
          jsonResponse["choices"].length,
              (index) => ChatModel(
            msg: jsonResponse["choices"][index]["message"]["content"],
            chatIndex: 1,
          ),
        );
      }
      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }




  // send messages fct
  static Future<List<ChatModel>> sendMessages({
    required String message,
    required String modelId,
  }) async{
    try{
      log("modelId $modelId");
      var response = await http.post
        (Uri.parse("$BASE_URL/chat/completions"),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "model": modelId,
          "messages": [{
            "role": "user",
            "content": message
          }],
          "max_tokens":300
        },
        ),
      );

      // Map jsonResponse = jsonDecode(response.body);
      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));

      if(jsonResponse['error']!=null){
        // log("jsonResponse[error] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse["error"]["message"]);
      }
      List<ChatModel> chatList=[];
      if(jsonResponse["choices"].length>0){
        // log("jsonResponse ${jsonResponse['choices'][0]['message']['content']}");
         chatList= List.generate(
           jsonResponse["choices"].length,
          (index) => ChatModel(
              msg:jsonResponse['choices'][index]['message']['content'] ,
              chatIndex: 1)
         );
      }
      return chatList;
    }catch(error){
      log("error $error");
      rethrow;
    }
  }
}