import 'package:flutter/material.dart';
import 'telegram_service.dart';
import 'package:tdlib/td_api.dart' as td;

void main() => runApp(const MaterialApp(home: AntiBlockApp()));

class AntiBlockApp extends StatefulWidget {
  const AntiBlockApp({super.key});
  @override
  State<AntiBlockApp> createState() => _AntiBlockAppState();
}

class _AntiBlockAppState extends State<AntiBlockApp> {
  final TelegramService _tgService = TelegramService();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  
  String status = "Загрузка...";
  bool isCodeSent = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() async {
    await _tgService.init();
    _listenLoop();
  }

  void _listenLoop() async {
    while (mounted) {
      final res = await _tgService.receive();
      if (res is td.UpdateAuthorizationState) {
        _handleAuth(res.authorizationState);
      }
    }
  }

  void _handleAuth(td.AuthorizationState state) {
    if (state is td.AuthorizationStateWaitPhoneNumber) {
      setState(() => status = "Введите номер");
    } else if (state is td.AuthorizationStateWaitCode) {
      setState(() {
        isCodeSent = true;
        status = "Введите код";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AntiBlock")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(status),
            TextField(controller: isCodeSent ? _codeController : _phoneController),
            ElevatedButton(
              onPressed: () {
                if (!isCodeSent) {
                  _tgService.send(td.SetAuthenticationPhoneNumber(
                    phoneNumber: _phoneController.text,
                    settings: const td.PhoneNumberAuthenticationSettings(),
                  ));
                } else {
                  _tgService.send(td.CheckAuthenticationCode(code: _codeController.text));
                }
              },
              child: const Text("Продолжить"),
            ),
          ],
        ),
      ),
    );
  }
}