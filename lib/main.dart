import 'package:flutter/material.dart';
import 'package:tdlib/td_api.dart' as td;
import 'package:tdlib/td_client.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const TelegramAuthPage(),
    );
  }
}

class TelegramAuthPage extends StatefulWidget {
  const TelegramAuthPage({super.key});
  @override
  State<TelegramAuthPage> createState() => _TelegramAuthPageState();
}

class _TelegramAuthPageState extends State<TelegramAuthPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  
  int? _clientId;
  bool isCodeSent = false;
  String status = "Ожидание инициализации...";

  // --- ДАННЫЕ ИЗ MY.TELEGRAM.ORG ---
  static const int apiId = 27998990; // ЗАМЕНИ НА СВОЙ
  static const String apiHash = '385a37e211351c656f93683ee888f284'; // ЗАМЕНИ НА СВОЙ

  @override
  void initState() {
    super.initState();
    _initTdlib();
  }

  Future<void> _initTdlib() async {
    _clientId = await TdClient.createClient();
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = "${appDir.path}/tdlib_db";

    // Настраиваем параметры клиента
    _send(td.SetTdlibParameters(
      databaseDirectory: dbPath,
      useMessageDatabase: true,
      useChatInfoDatabase: true,
      apiId: apiId,
      apiHash: apiHash,
      systemLanguageCode: 'ru',
      deviceModel: 'iPhone Test',
      systemVersion: 'iOS 17',
      applicationVersion: '1.0.0',
    ));

    setState(() => status = "Готов к подключению");
  }

  void _send(td.TdFunction event) {
    if (_clientId != null) {
      TdClient.nativeTdSend(_clientId!, event);
    }
  }

  // РЕАЛЬНЫЙ ПРОЦЕСС: Отправка номера
  void startAuth() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    setState(() => status = "Связь с серверами Telegram...");
    _send(td.SetAuthenticationPhoneNumber(phoneNumber: phone));
    
    // В реальности мы должны ждать UpdateAuthorizationState, 
    // но для начала просто переключим UI
    setState(() {
      isCodeSent = true;
      status = "Код запрошен на $phone";
    });
  }

  // РЕАЛЬНЫЙ ПРОЦЕСС: Проверка кода
  void verifyCode() {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    _send(td.CheckAuthenticationCode(code: code));
    
    // Переходим к чатам
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AntiBlock Real-Time")),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isCodeSent ? Icons.mark_email_read : Icons.hub, size: 60, color: Colors.blue),
              const SizedBox(height: 20),
              Text(status, textAlign: TextAlign.center),
              const SizedBox(height: 30),
              if (!isCodeSent) ...[
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: "Номер (+7...)"),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: startAuth, child: const Text("ПОЛУЧИТЬ КОД")),
                ),
              ] else ...[
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: "Код подтверждения"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: verifyCode, child: const Text("ВОЙТИ В ЧАТЫ")),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// --- ЭКРАН ЧАТОВ (Будем наполнять реальными данными позже) ---
class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Telegram Chats")),
      body: const Center(child: Text("Здесь скоро появятся твои реальные диалоги...")),
    );
  }
}