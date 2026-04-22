import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Убираем позорную красную плашку
      theme: ThemeData.dark(useMaterial3: true),
      home: const TelegramAuthPage(),
    );
  }
}

// --- ЭКРАН АВТОРИЗАЦИИ ---
class TelegramAuthPage extends StatefulWidget {
  const TelegramAuthPage({super.key});
  @override
  State<TelegramAuthPage> createState() => _TelegramAuthPageState();
}

class _TelegramAuthPageState extends State<TelegramAuthPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool isCodeSent = false;
  String status = "Готов к подключению";

  void fakeProcess() async {
    setState(() => status = "Обход блокировок... Загрузка прокси...");
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isCodeSent = true;
      status = "Код отправлен на ${_phoneController.text}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TG AntiBlock (Dev)")),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isCodeSent ? Icons.vibration : Icons.security, size: 60, color: Colors.blue),
              const SizedBox(height: 20),
              Text(status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 30),
              if (!isCodeSent) ...[
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: "Номер телефона",
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(onPressed: fakeProcess, child: const Text("ПОДКЛЮЧИТЬСЯ")),
                ),
              ] else ...[
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: "Код из Telegram",
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.withOpacity(0.2)),
                    onPressed: () {
                      // ПЕРЕХОД НА СЛЕДУЮЩИЙ ЭКРАН
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatsPage()),
                      );
                    },
                    child: const Text("ПОДТВЕРДИТЬ"),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => isCodeSent = false),
                  child: const Text("Назад"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// --- ЭКРАН СПИСКА ЧАТОВ ---
class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Мои чаты"),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView.builder(
        itemCount: 15, // Сделаем чуть больше чатов
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
            ),
            title: Text("Чат с другом №${index + 1}"),
            subtitle: const Text("Последнее сообщение получено через прокси..."),
            trailing: const Text("12:00"),
            onTap: () {
              // Тут можно будет добавить открытие чата
            },
          );
        },
      ),
    );
  }
}