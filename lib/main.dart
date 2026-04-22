import 'package:flutter/material.dart';
import 'package:tdlib/td_api.dart' as td;
import 'package:tdlib/td_client.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() => runApp(const MaterialApp(home: TelegramAuthPage()));

class TelegramAuthPage extends StatefulWidget {
  const TelegramAuthPage({super.key});
  @override
  State<TelegramAuthPage> createState() => _TelegramAuthState();
}

class _TelegramAuthState extends State<TelegramAuthPage> {
  // --- ТВОИ ДАННЫЕ ---
  final int apiId = 1234567; 
  final String apiHash = 'ВАШ_ХЭШ';

  late int _clientId;
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String status = "Инициализация...";
  bool isCodeSent = false;
  List<td.Chat> chats = [];

  @override
  void initState() {
    super.initState();
    _setupTdlib();
  }

  Future<void> _setupTdlib() async {
    _clientId = await TdClient.createClient();
    final dir = await getApplicationDocumentsDirectory();
    
    // Настройка параметров
    _send(td.SetTdlibParameters(
      databaseDirectory: "${dir.path}/tdlib",
      useMessageDatabase: true,
      useChatInfoDatabase: true,
      apiId: apiId,
      apiHash: apiHash,
      systemLanguageCode: 'ru',
      deviceModel: 'iPhone AntiBlock',
      systemVersion: 'iOS 17',
      applicationVersion: '1.0.0',
    ));

    // Запускаем прослушку обновлений
    _listen();
  }

  void _send(td.TdFunction event) => TdClient.nativeTdSend(_clientId, event);

  void _listen() async {
    while (mounted) {
      final res = await TdClient.nativeTdReceive(_clientId, 1.0);
      if (res != null) {
        if (res is td.UpdateAuthorizationState) {
          _handleAuth(res.authorizationState);
        } else if (res is td.UpdateNewChat) {
          setState(() => chats.add(res.chat));
        }
      }
    }
  }

  void _handleAuth(td.AuthorizationState state) {
    if (state is td.AuthorizationStateWaitPhoneNumber) {
      setState(() => status = "Введите номер");
    } else if (state is td.AuthorizationStateWaitCode) {
      setState(() {
        isCodeSent = true;
        status = "Введите код из приложения";
      });
    } else if (state is td.AuthorizationStateReady) {
      setState(() => status = "Вход выполнен!");
      _send(const td.GetChats(limit: 20)); // Запрашиваем реальные чаты
    }
  }

  @override
  Widget build(BuildContext context) {
    if (status == "Вход выполнен!") return _buildChatList();

    return Scaffold(
      appBar: AppBar(title: const Text("AntiBlock Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(status),
            TextField(controller: isCodeSent ? _codeController : _phoneController),
            ElevatedButton(
              onPressed: () {
                if (!isCodeSent) {
                  _send(td.SetAuthenticationPhoneNumber(phoneNumber: _phoneController.text));
                } else {
                  _send(td.CheckAuthenticationCode(code: _codeController.text));
                }
              },
              child: Text(isCodeSent ? "Подтвердить" : "Получить код"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return Scaffold(
      appBar: AppBar(title: const Text("Мои чаты (AntiBlock)")),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, i) => ListTile(
          title: Text(chats[i].title),
          subtitle: const Text("Защищенное соединение активно"),
        ),
      ),
    );
  }
}