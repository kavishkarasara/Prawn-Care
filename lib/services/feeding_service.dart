import 'dart:async';

import '../models/feeding_item.dart';
import 'supabase_service.dart';

class FeedingService {
  final StreamController<List<FeedingItem>> _feedingItemsController =
      StreamController.broadcast();
  Stream<List<FeedingItem>> get feedingItemsStream =>
      _feedingItemsController.stream;

  List<FeedingItem> _feedingItems = [];

  FeedingService() {
    _init();
  }

  void _init() {
    try {
      // Listen to Supabase real-time stream for feeding_items table
      print('Setting up real-time stream for feeding_items table');
      SupabaseService.streamTable(
              table: 'feeding_items', orderBy: 'scheduled_time')
          .listen((event) {
        try {
          _feedingItems = event.map((e) => FeedingItem.fromJson(e)).toList();
          _feedingItems
              .sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
          _feedingItemsController.add(_feedingItems);
          print('Updated feeding items list with ${event.length} items');
        } catch (e) {
          print('Error processing feeding items stream data: $e');
          print('Raw event data: $event');
        }
      }, onError: (error) {
        print('Error in feeding items stream: $error');
      }, onDone: () {
        print('Feeding items stream completed');
      });
    } catch (e) {
      print('Error setting up feeding items stream: $e');
    }
  }

  Future<void> addItem({
    required String tankName,
    required DateTime scheduledTime,
  }) async {
    try {
      final data = {
        'tank_name': tankName,
        'scheduled_time': scheduledTime.toIso8601String(),
        'is_completed': false,
        // Removed alarm_enabled as alarm functionality has been removed
        // 'alarm_enabled': alarmEnabled,
      };

      // Log the data being inserted for debugging
      print('Inserting feeding item: $data');

      final result =
          await SupabaseService.insert(table: 'feeding_items', data: data);

      // Log the result for debugging
      print('Insert result: $result');

      if (result.isEmpty) {
        throw Exception('Failed to insert feeding item - no data returned');
      }
    } catch (e) {
      print('Error adding feeding item: $e');
      rethrow;
    }
  }

  Future<void> removeItem(int id) async {
    try {
      print('Removing feeding item with id: $id');
      await SupabaseService.delete(
          table: 'feeding_items', conditions: {'id': id});
      print('Successfully removed feeding item with id: $id');
    } catch (e) {
      print('Error removing feeding item: $e');
      rethrow;
    }
  }

  Future<void> updateItemTime(int id, DateTime newTime) async {
    try {
      print(
          'Updating feeding item time for id: $id to: ${newTime.toIso8601String()}');
      await SupabaseService.update(
        table: 'feeding_items',
        data: {'scheduled_time': newTime.toIso8601String()},
        conditions: {'id': id},
      );
      print('Successfully updated feeding item time for id: $id');
    } catch (e) {
      print('Error updating feeding item time: $e');
      rethrow;
    }
  }

  // Removed toggleAlarm method as alarm functionality has been removed
  // Future<void> toggleAlarm(int id, bool currentValue) async {
  //   try {
  //     print(
  //         'Toggling alarm for feeding item id: $id from: $currentValue to: ${!currentValue}');
  //     await SupabaseService.update(
  //       table: 'feeding_items',
  //       data: {'alarm_enabled': !currentValue},
  //       conditions: {'id': id},
  //     );
  //     print('Successfully toggled alarm for feeding item id: $id');
  //   } catch (e) {
  //     print('Error toggling alarm for feeding item: $e');
  //     rethrow;
  //   }
  // }

  void dispose() {
    _feedingItemsController.close();
  }
}
