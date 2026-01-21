import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Sunucu ile WebSocket iletişimi için yönetici sınıf
class NetworkManager {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  
  // Bağlantı durumu
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  
  // Local Player ID captured from welcome message
  String? _localPlayerId;
  String? get localPlayerId => _localPlayerId;
  
  // State updates stream controller
  final _stateController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get stateStream => _stateController.stream;
  
  // Connection status stream
  final _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;
  
  /// Sunucuya bağlan
  /// [serverIp] örnek: "192.168.1.5" veya "localhost"
  /// [port] varsayılan: 8080
  Future<bool> connect(String serverIp, {int port = 8080}) async {
    try {
      final uri = Uri.parse('ws://$serverIp:$port/ws');
      _channel = WebSocketChannel.connect(uri);
      
      // Bağlantıyı doğrula
      await _channel!.ready;
      
      _isConnected = true;
      _connectionController.add(true);
      
      // Gelen mesajları dinle
      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data as String) as Map<String, dynamic>;
            
            // ID'yi sakla
            if (message['type'] == 'welcome') {
               final payload = message['payload'] as Map<String, dynamic>;
               _localPlayerId = payload['id'] as String;
               print("NetworkManager: Captured Local ID: $_localPlayerId");
            }
            
            _stateController.add(message);
          } catch (e) {
            // JSON parse hatası, yoksay
          }
        },
        onError: (error) {
          _isConnected = false;
          _connectionController.add(false);
        },
        onDone: () {
          _isConnected = false;
          _connectionController.add(false);
        },
      );
      
      return true;
    } catch (e) {
      _isConnected = false;
      _connectionController.add(false);
      return false;
    }
  }
  
  /// Sunucuya input gönder
  void sendInput({
    required double dx,
    required double dy,
    required double rotation,
    List<String> actions = const [],
  }) {
    if (!_isConnected || _channel == null) return;
    
    final message = {
      'type': 'input',
      'payload': {
        'dx': dx,
        'dy': dy,
        'rotation': rotation,
        'actions': actions,
      },
    };
    
    // Log movement/action
    if (dx != 0 || dy != 0 || actions.isNotEmpty) {
       print("NET_DEBUG: Sending Input (dx: $dx, dy: $dy, acts: $actions)");
    }
    
    _channel!.sink.add(jsonEncode(message));
  }
  
  /// Sunucuya katılma mesajı gönder
  void sendJoin(String playerName, {String roomId = ''}) {
    if (!_isConnected || _channel == null) return;
    
    final message = {
      'type': 'join',
      'payload': {
        'name': playerName,
        'roomId': roomId,
      },
    };
    
    _channel!.sink.add(jsonEncode(message));
  }
  
  /// Bağlantıyı kapat
  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    _connectionController.add(false);
  }
  
  /// Temizlik
  void dispose() {
    disconnect();
    _stateController.close();
    _connectionController.close();
  }
}
