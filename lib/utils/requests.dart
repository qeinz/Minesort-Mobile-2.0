import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

var baseUrl = "app.minesort.de";

String seckey = "";
int theme = 0;
int chatLength = 15;
String firebase = "";
bool android = false;
bool newDesignAccount = true;

String apikey = "";

String selfUid = "";

Future<http.Response> checkToken(String token) async {
  return await http.get(
      Uri.https(baseUrl, '/api/app/login', {'token': token, 'fcm': firebase}));
}

savesToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  seckey = token;
  prefs.setString('sectoken', token);
}

savesTheme(int token) async {
  final prefs = await SharedPreferences.getInstance();
  theme = token;
  prefs.setInt('theme', theme);
  switch (theme) {
    case 0:
      MyApp.themeNotifier.value = ThemeMode.system;
      break;
    case 1:
      MyApp.themeNotifier.value = ThemeMode.light;
      break;
    case 2:
      MyApp.themeNotifier.value = ThemeMode.dark;
      break;
  }
}

savesApikey(String token) async {
  final prefs = await SharedPreferences.getInstance();
  apikey = token;
  prefs.setString('apikey', token);
}

saveUid(String uid) async {
  final prefs = await SharedPreferences.getInstance();
  selfUid = uid;
  prefs.setString('uid', uid);
}

saveChatLength(int length) async {
  final prefs = await SharedPreferences.getInstance();
  chatLength = length;
  prefs.setInt('chatlength', chatLength);
}

saveAndroid(bool bool) async {
  final prefs = await SharedPreferences.getInstance();
  android = bool;
  prefs.setBool('andorid', android);
}

saveNewDesign(bool bool) async {
  final prefs = await SharedPreferences.getInstance();
  newDesignAccount = bool;
  prefs.setBool('newDesignAccount', newDesignAccount);
}

loadSettings() async {
  final prefs = await SharedPreferences.getInstance();
  newDesignAccount = prefs.getBool('newDesignAccount') ?? true;
  android = prefs.getBool('andorid') ?? false;
  chatLength = prefs.getInt('chatlength') ?? 15;
  selfUid = prefs.getString('uid') ?? "";
  apikey = prefs.getString('apikey') ?? "";
  theme = prefs.getInt('theme') ?? 0;
  seckey = prefs.getString('sectoken') ?? "";
}

String backendURL = "api.minesort.de";

Future<String> getInfosSectoken() async {
  var response = await http
      .get(Uri.https(backendURL, '/app/ts3/infos/seckey', {'seckey': seckey}));
  return response.body;
}

Future<String> getInfosFromApp() async {
  var response =
  await http.get(Uri.https(baseUrl, '/api/app/GET', {'sec_token': seckey}));
  return response.body;
}

Future<String> getUid() async {
  var response =
  await http.get(Uri.https(baseUrl, '/api/app/GET', {'sec_token': seckey}));
  selfUid = response.body.split(",")[0];
  await saveUid(selfUid);
  return selfUid;
}

Future<String> getContactsFromClient() async {
  var response = await http.get(
      Uri.https(backendURL, '/app/ts3/chat/getcontacts', {'seckey': seckey}));
  return response.body;
}

Future<String> getAllPossibleContacts() async {
  var response = await http.get(Uri.https(
      backendURL, '/app/ts3/chat/get/allpossibleusers', {'seckey': seckey}));
  return response.body;
}

Future<String> getTs3UsersFromFlutter() async {
  var response = await http
      .get(Uri.https(backendURL, '/flutter/ts3/users', {'apikey': apikey}));
  return response.body;
}

Future<String> sendPokeMessage(poke, targetUid) async {
  var response = await http.get(Uri.https(backendURL, '/app/ts3/poke', {
    'apikey': apikey,
    'uid': targetUid,
    'message': poke,
  }));
  return response.body;
}

Future<String> sendTeamChatMessage(text) async {
  var response =
  await http.get(Uri.https(backendURL, '/app/ts3/teamchat/post', {
    'apikey': apikey,
    'seckey': seckey,
    'text': text,
  }));
  return response.body;
}

Future<String> muteClient(targetUid) async {
  var response = await http.get(Uri.https(backendURL, '/ts3/mute', {
    'apikey': apikey,
    'uid': targetUid,
  }));
  return response.body;
}

Future<String> getClientInfos(targetUid) async {
  var response =
  await http.get(Uri.https(backendURL, '/flutter/ts3/user/infos', {
    'apikey': apikey,
    'uid': targetUid,
  }));
  return response.body;
}

Future<String> getClientMutedStatus(targetUid) async {
  var response =
  await http.get(Uri.https(backendURL, '/flutter/ts3/user/infos/muted', {
    'apikey': apikey,
    'uid': targetUid,
  }));
  return response.body;
}

Future<String> getClientBotCommands(targetUid) async {
  var response =
  await http.get(Uri.https(backendURL, '/flutter/ts3/user/commands', {
    'apikey': apikey,
    'uid': targetUid,
  }));
  return response.body;
}

Future<String> getClientLastChannels(targetUid) async {
  var response =
  await http.get(Uri.https(backendURL, '/flutter/ts3/user/lastchannel', {
    'apikey': apikey,
    'uid': targetUid,
  }));
  return response.body;
}

Future<String> kickClient(targetUid, reason) async {
  var response = await http.get(Uri.https(backendURL, '/ts3/kick', {
    'apikey': apikey,
    'uid': targetUid,
    'reason': reason,
  }));
  return response.body;
}

Future<String> banClient(targetUid, reason, duration) async {
  var response = await http.get(Uri.https(backendURL, '/ts3/ban', {
    'apikey': apikey,
    'uid': targetUid,
    'reason': reason,
    'duration': duration,
  }));
  return response.body;
}

Future<void> moveClient(targetUid) async {
  await http.get(Uri.https(backendURL, '/app/ts3/users/move', {
    'apikey': apikey,
    'movedUID': targetUid,
  }));
}

Future<String> getClientsCoinsLog(targetUid) async {
  var response = await http.get(Uri.https(backendURL, '/app/ts3/user/coins', {
    'apikey': apikey,
    'uid': targetUid,
  }));
  return response.body;
}

Future<String> getClientsConnectionsLog(targetUid) async {
  var response =
  await http.get(Uri.https(backendURL, '/app/ts3/user/connections', {
    'apikey': apikey,
    'uid': targetUid,
  }));
  return response.body;
}

Future<String> getClientsBanLog(targetUid) async {
  var response = await http.get(Uri.https(backendURL, '/app/ts3/user/banns', {
    'apikey': apikey,
    'uid': targetUid,
  }));
  return response.body;
}

Future<String> editCoinsClient(targetUid, coins, operation) async {
  var response = await http.get(Uri.https(backendURL, '/ts3/user/coins', {
    'apikey': apikey,
    'uid': targetUid,
    'coins': coins,
    'operation': operation,
  }));
  return response.body;
}

Future<String> getChatByClientData(pair) async {
  var response = await http.get(Uri.https(backendURL, '/app/ts3/chat/get', {
    'seckey': seckey,
    'pair': pair,
    'length': chatLength.toString(),
  }));
  return response.body;
}

Future<String> removeChatContactByClient(targetUid) async {
  var response =
  await http.get(Uri.https(backendURL, '/app/ts3/chat/removecontact', {
    'seckey': seckey,
    'contactuid': targetUid,
  }));
  return response.body;
}

Future<String> emptyChatContactByClient(pair, targetUid) async {
  var response = await http.get(Uri.https(backendURL, '/app/ts3/chat/clear', {
    'seckey': seckey,
    'pairid': pair,
  }));
  return response.body;
}

Future<String> addChatContactByClient(targetUid) async {
  var response =
  await http.get(Uri.https(backendURL, '/app/ts3/chat/addcontact', {
    'seckey': seckey,
    'contactuid': targetUid,
  }));
  return response.body;
}

Future<String> postPrivatChatByClient(
    String pair, String message, String recieveruid) async {
  Map<String, String> data = {
    'seckey': seckey,
    'recieverUID': recieveruid,
    'pairID': pair,
    'message': message,
  };
  String jsonData = jsonEncode(data);

  var response = await http.post(
    Uri.https(backendURL, '/app/ts3/chat/post/v2'),
    headers: {"Content-Type": "application/json"},
    body: jsonData,
  );
  return response.body;
}

Future<String> getTeamchatMessages() async {
  var response =
  await http.get(Uri.https(backendURL, '/v2/app/ts3/teamchat/get', {
    'apikey': apikey,
    'length': chatLength.toString(),
  }));
  return response.body;
}

Future<String> getApiKey(String seckey) async {
  var response =
  await http.get(Uri.https(backendURL, '/flutter/ts3/user/getapikey', {
    'seckey': seckey,
  }));
  savesApikey(response.body);
  return response.body;
}

Future<void> sendToken(String token) async {
  await http.get(Uri.https(backendURL, '/app/ts3/login/token/verify', {
    'securitytoken': seckey,
    'watchtower': token,
  }));
}


Future<List<String?>> getBadwordsList() async {
  final response = await http.get(Uri.https(backendURL, '/security/badwords',
      {'apikey': apikey, 'operation': 'list'}));

  if (response.statusCode == 200) {
    final List<String> data = response.body.split(',');
    data.removeLast();
    return List<String?>.from(data);
  } else {
    throw Exception('Failed to load badwords list');
  }
}

Future<String> getOfflineUser() async {
  final response = await http.get(Uri.https(backendURL, '/app/ts3/get/all/user',
      {'apikey': apikey}));
    return response.body;
}

Future<bool> getBadwordsStatus() async {
  final response = await http.get(Uri.https(backendURL, '/security/enabled', {
    'apikey': apikey,
  }));
  if (response.body.toString().split(" ")[1] == "enabled") {
    return true;
  } else {
    return false;
  }
}

Future<void> setBotStatus(String enable) async {
  await http.get(Uri.https(backendURL, '/security/badwords', {
    'apikey': apikey,
    'enable': enable,
  }));
}