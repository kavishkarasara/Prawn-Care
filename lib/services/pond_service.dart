// lib/services/pond_service.dart

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/pond_condition.dart';

class PondService {
  // Singleton pattern to ensure all widgets use the same instance
  static final PondService _instance = PondService._internal();

  factory PondService() {
    return _instance;
  }

  PondService._internal();

  Map<String, PondCondition> ponds = {
    'pond1': PondCondition(
      id: 'pond1',
      pondName: 'Main Pond',
      baseUrl: 'http://192.168.1.127',
      phBaseUrl: 'http://192.168.1.113',
      lastUpdated: DateTime.now(),
    ),
  };

  // Stream controller for real-time updates
  final StreamController<Map<String, PondCondition>> _pondsController =
      StreamController<Map<String, PondCondition>>.broadcast();

  // Stream to expose pond data updates
  Stream<Map<String, PondCondition>> get pondsStream => _pondsController.stream;

  // Timer for periodic updates
  Timer? _updateTimer;

  // Flag to control updates
  bool _isUpdating = false;

  Future<Map<String, dynamic>> fetchPondData(String pondId) async {
    final pond = ponds[pondId];
    if (pond == null) {
      return {'error': 'Pond not found'};
    }

    try {
      // Fetch data from individual endpoints
      final results = await Future.wait([
        _fetchParameter('${pond.baseUrl}/waterlevel', 'waterLevel'),
        _fetchParameter('${pond.baseUrl}/tds', 'clarity'),
        _fetchParameter('${pond.phBaseUrl}/ph', 'phLevel'),
        _fetchParameter('${pond.baseUrl}/temperature', 'temperature'),
      ]);

      final waterLevel =
          double.tryParse(results[0]['value']?.toString() ?? '0') ?? 0.0;
      final clarity =
          double.tryParse(results[1]['value']?.toString() ?? '0') ?? 0.0;

      final phLevel =
          double.tryParse(results[2]['value']?.toString() ?? '0') ?? 0.0;
      final temperature =
          double.tryParse(results[3]['value']?.toString() ?? '0') ?? 0.0;

      final isConnected = results.any((result) => result['success'] == true);

      // Update the pond in the map with fetched data
      final updatedPond = PondCondition(
        id: pond.id,
        pondName: pond.pondName,
        baseUrl: pond.baseUrl,
        phBaseUrl: pond.phBaseUrl,
        waterLevel: waterLevel,
        clarity: clarity,
        phLevel: phLevel,
        temperature: temperature,
        isConnected: isConnected,
        lastUpdated: DateTime.now(),
      );
      ponds[pondId] = updatedPond;

      return {
        'pond': {
          'id': updatedPond.id,
          'pondName': updatedPond.pondName,
          'baseUrl': updatedPond.baseUrl,
          'waterLevel': waterLevel,
          'clarity': clarity,
          'phLevel': phLevel,
          'temperature': temperature,
          'isConnected': isConnected,
        },
        'success': true,
      };
    } catch (e) {
      return {
        'error': 'Failed to fetch data: $e',
        'success': false,
      };
    }
  }

  Future<Map<String, dynamic>> _fetchParameter(
      String url, String parameterName) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          String valueKey = 'value';
          if (parameterName == 'temperature') {
            valueKey =
                jsonData.containsKey('waterTemp') ? 'waterTemp' : 'value';
          } else if (parameterName == 'waterLevel') {
            valueKey = jsonData.containsKey('waterLevelInside')
                ? 'waterLevelInside'
                : (jsonData.containsKey('waterLevel') ? 'waterLevel' : 'value');
          } else if (parameterName == 'clarity') {
            valueKey = jsonData.containsKey('tds') ? 'tds' : 'value';
          } else if (parameterName == 'phLevel') {
            valueKey = jsonData.containsKey('pH') ? 'pH' : 'value';
          }
          final extractedValue =
              jsonData[valueKey] ?? jsonData[parameterName] ?? response.body;
          return {
            'success': true,
            'value': extractedValue,
          };
        } catch (e) {
          return {
            'success': true,
            'value': response.body,
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      if (e.toString().contains('timeout') ||
          e.toString().contains('Timeout')) {
        return {
          'success': false,
          'error': 'Timeout',
        };
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> fetchAllPonds() async {
    // Return all ponds, not just connected ones
    final allPonds = ponds.values.toList();

    return {
      'ponds': allPonds,
      'success': allPonds.isNotEmpty,
    };
  }

  Map<String, dynamic> getCurrentPondsData() {
    final allPonds = ponds.values.toList();
    return {
      'ponds': allPonds,
      'success': allPonds.isNotEmpty,
    };
  }

  void addPond(PondCondition pond) {
    ponds[pond.id] = pond;
  }

  void removePond(String pondId) {
    ponds.remove(pondId);
  }

  Future<Map<String, dynamic>> fetchPondByIpAddress(String ipAddress) async {
    final pond = ponds.values.firstWhere(
      (p) => p.baseUrl.contains(ipAddress),
      orElse: () => throw Exception('Pond with IP $ipAddress not found'),
    );

    return await fetchPondData(pond.id);
  }

  Future<void> addPondWithIp(
      String pondName, String ipAddress, String phIpAddress) async {
    final pondId = 'pond${ponds.length + 1}';
    final newPond = PondCondition(
      id: pondId,
      pondName: pondName,
      baseUrl: 'http://$ipAddress',
      phBaseUrl: 'http://$phIpAddress',
      lastUpdated: DateTime.now(),
    );

    addPond(newPond);

    // Fetch data immediately after adding
    await fetchPondData(pondId);

    // Notify stream listeners
    _pondsController.add(Map.from(ponds));
  }

  // Start real-time updates
  void startRealTimeUpdates() {
    if (_isUpdating) return;

    _isUpdating = true;
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!_isUpdating) return;

      final pondIds = ponds.keys.toList();
      for (final pondId in pondIds) {
        try {
          await fetchPondData(pondId);
        } catch (e) {
          // Log error but continue with other ponds
        }
      }

      // Emit updated data to stream
      if (!_pondsController.isClosed) {
        _pondsController.add(Map.from(ponds));
      }
    });
  }

  // Stop real-time updates
  void stopRealTimeUpdates() {
    _isUpdating = false;
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  // Dispose method to clean up resources
  void dispose() {
    stopRealTimeUpdates();
    _pondsController.close();
  }

  // Get current ponds data (for backward compatibility)
  Map<String, PondCondition> get currentPonds => Map.from(ponds);
}
