import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:prawn__farm/models/message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient? _client;

  /// 🔹 Initialize Supabase (Call in main.dart)
  static Future<void> initialize({
    required String url,
    required String anonKey,
    bool debug = true,
  }) async {
    try {
      if (!url.startsWith('http')) {
        throw Exception('Invalid Supabase URL format: $url');
      }

      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        debug: debug,
      );

      _client = Supabase.instance.client;
      if (debug) {
        developer.log('✅ Supabase initialized');
        developer.log('📍 Project: $url');
      }
    } catch (e) {
      developer.log('❌ Supabase init failed: $e');
      rethrow;
    }
  }

  /// 🔹 Get Supabase client
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
          'Supabase not initialized. Call SupabaseService.initialize() first.');
    }
    return _client!;
  }

  /// 🔹 Authentication
  static bool get isAuthenticated => client.auth.currentUser != null;
  static User? get currentUser => client.auth.currentUser;
  static String? get currentUserId => client.auth.currentUser?.id;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      return await client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// 🔹 Database CRUD
  /// Select multiple rows with optional conditions.
  static Future<List<Map<String, dynamic>>> select({
    required String table,
    String columns = '*',
    Map<String, dynamic>? conditions,
    int? limit,
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      dynamic query = client.from(table).select(columns);

      if (conditions != null) {
        conditions.forEach((key, value) {
          if (value is List) {
            query = query.inFilter(key, value);
          } else {
            query = query.eq(key, value);
          }
        });
      }

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      if (limit != null) {
        query = query.range(0, limit - 1);
      }

      return List<Map<String, dynamic>>.from(await query);
    } catch (e) {
      throw Exception('Failed to select from $table: $e');
    }
  }

  /// Select a single row with optional conditions.
  static Future<Map<String, dynamic>?> selectSingle({
    required String table,
    String columns = '*',
    Map<String, dynamic>? conditions,
  }) async {
    try {
      var query = client.from(table).select(columns);

      if (conditions != null) {
        conditions.forEach((key, value) {
          query = query.eq(key, value);
        });
      }

      final result = await query.maybeSingle();
      return result;
    } catch (e) {
      throw Exception('Failed to select single from $table: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> insert({
    required String table,
    required dynamic data, // Can be Map or List<Map>
    bool upsert = false,
  }) async {
    try {
      if (upsert) {
        return List<Map<String, dynamic>>.from(
            await client.from(table).upsert(data).select());
      } else {
        return List<Map<String, dynamic>>.from(
            await client.from(table).insert(data).select());
      }
    } catch (e) {
      throw Exception('Failed to insert into $table: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> update({
    required String table,
    required Map<String, dynamic> data,
    required Map<String, dynamic> conditions,
  }) async {
    try {
      dynamic query = client.from(table).update(data);

      conditions.forEach((key, value) {
        query = query.eq(key, value);
      });

      return List<Map<String, dynamic>>.from(await query.select());
    } catch (e) {
      throw Exception('Failed to update $table: $e');
    }
  }

  static Future<void> delete({
    required String table,
    required Map<String, dynamic> conditions,
  }) async {
    try {
      dynamic query = client.from(table).delete();

      conditions.forEach((key, value) {
        query = query.eq(key, value);
      });
      await query;
    } catch (e) {
      throw Exception('Failed to delete from $table: $e');
    }
  }

  /// 🔹 Advanced query methods
  static Future<int> count({
    required String table,
    Map<String, dynamic>? conditions,
  }) async {
    try {
      var query = client.from(table).count(CountOption.exact);

      if (conditions != null) {
        conditions.forEach((key, value) {
          query = query.eq(key, value);
        });
      }

      final int count = await query;
      return count;
    } catch (e) {
      throw Exception('Failed to count $table: $e');
    }
  }

  /// 🔹 Storage
  static Future<String> uploadFile({
    required String bucket,
    required String path,
    required List<int> fileBytes,
    String? contentType,
    bool upsert = true,
  }) async {
    try {
      final Uint8List bytes = Uint8List.fromList(fileBytes);
      await client.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: upsert,
            ),
          );
      return client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      throw Exception('Failed to upload file to $bucket/$path: $e');
    }
  }

  static Future<List<int>> downloadFile({
    required String bucket,
    required String path,
  }) async {
    try {
      return await client.storage.from(bucket).download(path);
    } catch (e) {
      throw Exception('Failed to download file from $bucket/$path: $e');
    }
  }

  static Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await client.storage.from(bucket).remove([path]);
    } catch (e) {
      throw Exception('Failed to delete file from $bucket/$path: $e');
    }
  }

  static Future<List<FileObject>> listFiles({
    required String bucket,
    String? path,
    int? limit,
  }) async {
    try {
      return await client.storage.from(bucket).list(
            path: path,
            searchOptions: SearchOptions(limit: limit),
          );
    } catch (e) {
      throw Exception('Failed to list files in $bucket: $e');
    }
  }

  /// 🔹 Realtime
  /// Corrected: Removed the redundant .map() call which caused the type error.
  static Stream<List<Map<String, dynamic>>> streamTable({
    required String table,
    Map<String, dynamic>? conditions,
    String orderBy = 'created_at',
    bool ascending = true,
  }) {
    dynamic stream = client.from(table).stream(primaryKey: ['id']);
    if (conditions != null) {
      conditions.forEach((key, value) {
        stream = stream.eq(key, value);
      });
    }
    return stream.order(orderBy, ascending: ascending);
  }

  /// 🔹 Auth State Listener
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  /// 🔹 Extra Auth Helpers
  static Future<void> resetPassword({required String email}) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  static Future<void> signInWithOtp({required String email}) async {
    try {
      await client.auth.signInWithOtp(email: email);
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  static Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    try {
      return await client.auth.verifyOTP(
        email: email,
        token: token,
        type: type,
      );
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  /// 🔹 Social Auth
  static Future<bool> signInWithProvider(OAuthProvider provider) async {
    try {
      await client.auth.signInWithOAuth(provider);
      return true;
    } catch (e) {
      throw Exception('Failed to sign in with ${provider.name}: $e');
    }
  }

  /// 🔹 RPC (Remote Procedure Call) support
  static Future<dynamic> rpc({
    required String functionName,
    Map<String, dynamic>? params,
  }) async {
    try {
      return await client.rpc(functionName, params: params);
    } catch (e) {
      throw Exception('RPC call to $functionName failed: $e');
    }
  }

  /// 🔹 NOTIFICATION METHODS
  /// Get real-time notifications for a specific supplier
  static Stream<List<Map<String, dynamic>>> getNotificationsStream(
      String supplierId) {
    return streamTable(
      table: 'notifications',
      conditions: {'supplier_id': supplierId},
      orderBy: 'created_at',
      ascending: false,
    );
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    await update(
      table: 'notifications',
      data: {'is_read': true},
      conditions: {'id': notificationId},
    );
  }

  /// Mark all notifications as read for a supplier
  static Future<void> markAllNotificationsAsRead(String supplierId) async {
    await update(
      table: 'notifications',
      data: {'is_read': true},
      conditions: {'supplier_id': supplierId, 'is_read': false},
    );
  }

  /// Get unread notification count
  static Future<int> getUnreadNotificationCount(String supplierId) async {
    return await count(
      table: 'notifications',
      conditions: {'supplier_id': supplierId, 'is_read': false},
    );
  }

  /// Send notification
  static Future<void> sendNotification({
    required String supplierId,
    required String type,
    required String title,
    required String message,
  }) async {
    await insert(
      table: 'notifications',
      data: {
        'supplier_id': supplierId,
        'type': type,
        'title': title,
        'message': message,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  /// 🔹 REQUEST METHODS
  /// Save chemical request to database
  static Future<void> saveChemicalRequest({
    required String supplierId,
    required List<Map<String, dynamic>> chemicals,
    required String message,
  }) async {
    await insert(
      table: 'chemical_requests',
      data: {
        'supplier_id': supplierId,
        'chemicals': chemicals,
        'message': message,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Get chemical requests history
  static Stream<List<Map<String, dynamic>>> getChemicalRequests(
      String supplierId) {
    return streamTable(
      table: 'chemical_requests',
      conditions: {'supplier_id': supplierId},
      orderBy: 'created_at',
      ascending: false,
    );
  }

  /// Save feed request to database
  static Future<void> saveFeedRequest({
    required String supplierId,
    required List<Map<String, dynamic>> feeds,
    required String message,
  }) async {
    await insert(
      table: 'feed_requests',
      data: {
        'supplier_id': supplierId,
        'feeds': feeds,
        'message': message,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Get feed requests history
  static Stream<List<Map<String, dynamic>>> getFeedRequests(String supplierId) {
    return streamTable(
      table: 'feed_requests',
      conditions: {'supplier_id': supplierId},
      orderBy: 'created_at',
      ascending: false,
    );
  }

  /// Save equipment request to database
  static Future<void> saveEquipmentRequest({
    required String supplierId,
    required List<Map<String, dynamic>> equipment,
    required String message,
  }) async {
    await insert(
      table: 'equipment_requests',
      data: {
        'supplier_id': supplierId,
        'equipment': equipment,
        'message': message,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Get equipment requests history
  static Stream<List<Map<String, dynamic>>> getEquipmentRequests(
      String supplierId) {
    return streamTable(
      table: 'equipment_requests',
      conditions: {'supplier_id': supplierId},
      orderBy: 'created_at',
      ascending: false,
    );
  }

  /// 🔹 Helper methods for your specific use case
  /// Get messages for a supplier
  static Future<List<Map<String, dynamic>>> getMessages(
      String supplierId) async {
    return await select(
      table: 'messages',
      conditions: {'supplier_id': supplierId},
      orderBy: 'created_at',
      ascending: false, // Most recent first
    );
  }

  /// Get messages stream for a supplier
  static Stream<List<Message>> getMessagesStream(String supplierId) {
    return streamTable(
      table: 'messages',
      conditions: {'supplier_id': supplierId},
      orderBy: 'created_at',
    ).map((list) => list.map((map) => Message.fromJson(map)).toList());
  }

  /// Send message
  static Future<void> sendMessage(String supplierId, String text) async {
    await insert(
      table: 'messages',
      data: {
        'supplier_id': supplierId,
        'text': text,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  /// 🔹 FEEDING ITEM METHODS
  /// Fetch all feeding items, ordered by scheduled time.
  static Future<List<Map<String, dynamic>>> getFeedingItems() async {
    return await select(
      table: 'feeding_items',
      orderBy: 'scheduled_time',
      ascending: true,
    );
  }

  /// Add a new feeding item to the database.
  static Future<void> addFeedingItem({
    required String tankName,
    required DateTime scheduledTime,
    bool alarmEnabled = true,
  }) async {
    await insert(
      table: 'feeding_items',
      data: {
        'tank_name': tankName,
        'scheduled_time': scheduledTime.toIso8601String(),
        'is_completed': false,
        'alarm_enabled': alarmEnabled,
      },
    );
  }

  /// Remove a feeding item by its ID.
  static Future<void> removeFeedingItem(int id) async {
    await delete(
      table: 'feeding_items',
      conditions: {'id': id},
    );
  }

  /// Update the scheduled time of a feeding item.
  static Future<void> updateFeedingItemTime(int id, DateTime newTime) async {
    await update(
      table: 'feeding_items',
      data: {'scheduled_time': newTime.toIso8601String()},
      conditions: {'id': id},
    );
  }

  /// Toggle the alarm for a feeding item.
  static Future<void> toggleFeedingItemAlarm(int id) async {
    final item = await selectSingle(
      table: 'feeding_items',
      conditions: {'id': id},
      columns: 'alarm_enabled',
    );
    if (item != null) {
      await update(
        table: 'feeding_items',
        data: {'alarm_enabled': !(item['alarm_enabled'] as bool)},
        conditions: {'id': id},
      );
    }
  }

  /// Mark a feeding item as completed.
  static Future<void> markFeedingItemAsCompleted(int id) async {
    await update(
      table: 'feeding_items',
      data: {'is_completed': true},
      conditions: {'id': id},
    );
  }

  /// 🔹 Utility methods
  static bool get isInitialized => _client != null;

  /// Dispose resources (call when app closes)
  static void dispose() {
    _client = null;
  }

  // Re-implemented to call the existing private method
  static Future<int> getUnreadCount(String supplierId) async {
    return await getUnreadNotificationCount(supplierId);
  }

  // Re-implemented to call the existing private method
  static Future<void> markAllAsRead(String supplierId) async {
    await markAllNotificationsAsRead(supplierId);
  }
}
