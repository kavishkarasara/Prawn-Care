import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/special_note.dart';
import 'supabase_service.dart';

class SpecialNoteService {
  final StreamController<List<SpecialNote>> _specialNotesController =
      StreamController.broadcast();
  Stream<List<SpecialNote>> get specialNotesStream =>
      _specialNotesController.stream;

  List<SpecialNote> _specialNotes = [];

  SpecialNoteService() {
    _init();
  }

  void _init() {
    // Listen to auth state changes to set up stream when authenticated
    SupabaseService.authStateChanges.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn) {
        _setupStream();
      } else if (authState.event == AuthChangeEvent.signedOut) {
        _specialNotes = [];
        _specialNotesController.add(_specialNotes);
        print('Cleared special notes on sign out');
      }
    });

    // If already authenticated, set up stream immediately
    if (SupabaseService.isAuthenticated) {
      _setupStream();
    }
  }

  void _setupStream() {
    try {
      // Listen to Supabase real-time stream for special_notes table
      print('Setting up real-time stream for special_notes table');
      SupabaseService.streamTable(table: 'special_notes', orderBy: 'created_at')
          .listen((event) {
        try {
          _specialNotes = event.map((e) => SpecialNote.fromJson(e)).toList();
          _specialNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _specialNotesController.add(_specialNotes);
          print('Updated special notes list with ${event.length} items');
        } catch (e) {
          print('Error processing special notes stream data: $e');
          print('Raw event data: $event');
        }
      }, onError: (error) {
        print('Error in special notes stream: $error');
      }, onDone: () {
        print('Special notes stream completed');
      });
    } catch (e) {
      print('Error setting up special notes stream: $e');
    }
  }

  Future<void> addNote({
    required String userId,
    required String title,
    required String content,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'title': title,
        'content': content,
        'status': 'Pending',
      };

      print('Inserting special note: $data');

      final result =
          await SupabaseService.insert(table: 'special_notes', data: data);

      print('Insert result: $result');

      if (result.isEmpty) {
        throw Exception('Failed to insert special note - no data returned');
      }
    } catch (e) {
      print('Error adding special note: $e');
      rethrow;
    }
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    try {
      final data = {
        'title': title,
        'content': content,
      };

      print('Updating special note id $id with data: $data');

      await SupabaseService.update(
        table: 'special_notes',
        data: data,
        conditions: {'id': id},
      );

      print('Successfully updated special note id $id');
    } catch (e) {
      print('Error updating special note: $e');
      rethrow;
    }
  }

  Future<void> removeNote(String id) async {
    try {
      print('Removing special note with id: $id');
      await SupabaseService.delete(
          table: 'special_notes', conditions: {'id': id});
      print('Successfully removed special note with id: $id');
    } catch (e) {
      print('Error removing special note: $e');
      rethrow;
    }
  }

  int getPendingNotesCount() {
    return _specialNotes.where((note) => note.status == 'Pending').length;
  }

  void dispose() {
    _specialNotesController.close();
  }
}
