import 'package:tdlib/td_api.dart' as td;
import 'package:tdlib/td_client.dart' as td_client;
import 'package:path_provider/path_provider.dart';

class TelegramService {
  int? _clientId;
  
  // ВСТАВЬ СВОИ ДАННЫЕ ТУТ
  final int apiId = 27998990; 
  final String apiHash = '385a37e211351c656f93683ee888f284';

  // Инициализация клиента
  Future<void> init() async {
    _clientId = await td_client.TdClient.create();
    final dir = await getApplicationDocumentsDirectory();

    send(td.SetTdlibParameters(
      databaseDirectory: "${dir.path}/tdlib_db",
      filesDirectory: "${dir.path}/tdlib_files",
      useMessageDatabase: true,
      useChatInfoDatabase: true,
      apiId: apiId,
      apiHash: apiHash,
      systemLanguageCode: 'ru',
      deviceModel: 'iPhone AntiBlock',
      systemVersion: 'iOS 17',
      applicationVersion: '1.0.0',
      useTestDc: false,
    ));
  }

  // Общий метод отправки команд
  void send(td.TdFunction event) {
    if (_clientId != null) {
      td_client.TdClient.send(_clientId!, event);
    }
  }

  // Метод получения обновлений (будем вызывать его в цикле)
  Future<td.TdObject?> receive() async {
    if (_clientId == null) return null;
    return await td_client.TdClient.receive(_clientId!, 1.0);
  }

  // Твои кастомные фишки пойдут сюда
  void setInvisibleMode(bool isEnabled) {
    // Пример фишки: отключаем отправку статуса "Прочитано"
    // send(td.SetOption(name: 'disable_read_notification', value: td.OptionValueBoolean(value: isEnabled)));
  }
}