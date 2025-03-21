import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Importe para usar MediaType
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isMonitoring = false;
  bool _isNear = false;
  late IO.Socket _socket;
  CameraController? _cameraController;

  final String serverUrl = 'http://192.168.1.26:8000';

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _initializeCamera();
    _initializeProximitySensor();
  }

  // Configuração do WebSocket
  void _initializeSocket() {
    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket.onConnect((_) => print("✅ Conectado ao servidor!"));
    _socket.onDisconnect((_) => print("❌ Desconectado do servidor!"));
    _socket.onError((error) => print("🚨 Erro no WebSocket: $error"));

    _socket.connect(); // Conecta ao servidor
  }

  // Configuração da Câmera
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => throw Exception("Nenhuma câmera frontal encontrada"));

      _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
      await _cameraController!.initialize();
      setState(() {});
      print("📷 Câmera inicializada!");
    } catch (e) {
      print("❌ Erro ao inicializar a câmera: $e");
    }
  }

  // Configuração do Sensor de Proximidade
  void _initializeProximitySensor() {
    ProximitySensor.events.listen((event) {
      bool isNear = event == 1; // Sensor detectou proximidade
      setState(() => _isNear = isNear);

      if (_isMonitoring && isNear) {
        Future.delayed(Duration(milliseconds: 500), _sendAlert);
      }
    });
  }

  // Envio de Alerta ao Servidor
  void _sendAlert() async {
    if (!_isMonitoring || _cameraController == null || !_cameraController!.value.isInitialized) {
      print("⚠️ Monitoramento inativo ou câmera não inicializada!");
      return;
    }

    print("🚨 Enviando alerta...");
    _socket.emit('alert', 'ALERT');

    try {
      XFile image = await _cameraController!.takePicture();
      print("📸 Imagem capturada: ${image.path}");
      _uploadImage(image);
    } catch (e) {
      print("❌ Erro ao capturar imagem: $e");
    }
  }

  // Envio da Imagem para o Servidor
  Future<void> _uploadImage(XFile image) async {
    print("📤 Enviando imagem para o servidor...");

    try {
      final request = http.MultipartRequest('POST', Uri.parse('$serverUrl/upload-image/'))
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ));

      final response = await request.send();

      if (response.statusCode == 200) {
        print("✅ Imagem enviada com sucesso!");
      } else {
        print("❌ Erro ao enviar imagem! Código: ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 Erro no envio da imagem: $e");
    }
  }

  // Parar o Alarme no Servidor
  Future<void> _stopAlarm() async {
    try {
      final response = await http.post(Uri.parse('$serverUrl/stop-alarm/'));
      if (response.statusCode == 200) {
        print("🔇 Alarme parado!");
      } else {
        print("❌ Erro ao parar o alarme! Código: ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 Erro ao tentar parar o alarme: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sensor de Proximidade')),
      body: Column(
        children: [
          Expanded(
            child: _cameraController != null && _cameraController!.value.isInitialized
                ? CameraPreview(_cameraController!)
                : Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(_isNear ? '🔍 Objeto próximo!' : '✅ Nenhum objeto detectado'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isMonitoring = !_isMonitoring;
                      print("📢 Monitoramento: ${_isMonitoring ? 'ATIVADO' : 'DESATIVADO'}");
                    });
                  },
                  child: Text(_isMonitoring ? 'Desativar Monitoramento' : 'Ativar Monitoramento'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sendAlert,
                  child: Text("Testar Envio Manual"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await _stopAlarm();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Alarme parado com sucesso!")),
                    );
                  },
                  child: Text("Parar Alarme"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}