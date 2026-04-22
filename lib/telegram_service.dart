import 'dart:ffi';
import 'dart:io';
import 'package:tdlib_dart/tdlib_dart.dart';
import 'package:path_provider/path_provider.dart';

class TelegramService {
  late int _clientId;
  bool _isInitialized = false;

  // ТВОИ ДАННЫЕ С MY.TELEGRAM.ORG
  final int apiId = 27998990; 
  final String apiHash = '385a37e211351c656f93683ee888f284';

  Future<void> init() async {
    if (_isInitialized) return;
    
    // 1. Создаем клиент
    _clientId = Tdlib.createClient();
    
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = "${dir.path}/tdlib";

    // 2. Отправляем параметры (это ПЕРВЫЙ шаг для входа)
    _send(SetTdlibParameters(
      apiId: apiId,
      apiHash: apiHash,
      systemLanguageCode: 'ru',
      deviceModel: 'iPhone',
      systemVersion: 'iOS 17',
      applicationVersion: '1.0.0',
      databaseDirectory: dbPath,
      useMessageDatabase: true,
      useChatInfoDatabase: true,
      useSecretChats: true,
    ));
    
    _isInitialized = true;
    _listenLoop(); // Начинаем слушать ответы от серверов TG
  }

  void _send(TdFunction event) {
    Tdlib.clientSend(_clientId, event);
  }

  // Запрос кода на номер
  void sendPhone(String phone) {
    _send(SetAuthenticationPhoneNumber(phoneNumber: phone));
  }

  // Ввод кода
  void sendCode(String code) {
    _send(CheckAuthenticationCode(code: code));
  }

  // Бесконечный цикл прослушивания обновлений (здесь прилетают ЧАТЫ)
  void _listenLoop() async {
    while (true) {
      final event = Tdlib.clientReceive(_clientId, 1.0);
      if (event != null) {
        print("Новое событие от Telegram: ${event.runtimeType}");
        // Здесь мы будем ловить список чатов (UpdateNewChat)
      }
    }
  }
}