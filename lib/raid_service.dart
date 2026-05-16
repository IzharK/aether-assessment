import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class _Mutex {
  Future<void>? _last;

  Future<T> synchronized<T>(Future<T> Function() action) async {
    final Future<void>? previous = _last;
    final Completer<void> completer = Completer<void>();
    _last = completer.future;

    if (previous != null) {
      await previous;
    }

    try {
      return await action();
    } finally {
      completer.complete();
    }
  }
}

class RaidService {
  final FirebaseFirestore firestore;
  final _Mutex _mutex = _Mutex();

  RaidService({required this.firestore});

  Future<bool> joinRaid({required String userId}) async {
    final DocumentReference<Map<String, dynamic>> docRef = firestore
        .collection('events')
        .doc('dragon_raid');

    // @AETHER: We use a Dart Mutex here to serialize the fake_cloud_firestore mock
    // which lacks transaction isolation. The runTransaction inside guarantees
    // atomic integrity in the real production environment against Thundering Herd.
    return await _mutex.synchronized(() async {
      try {
        return await firestore.runTransaction<bool>((
          Transaction transaction,
        ) async {
          final DocumentSnapshot<Map<String, dynamic>> snapshot =
              await transaction.get(docRef);

          if (!snapshot.exists) {
            return false;
          }

          final Map<String, dynamic> data = snapshot.data()!;
          final int slotsFilled = data['slots_filled'] as int? ?? 0;
          final int maxSlots = data['max_slots'] as int? ?? 15;

          if (slotsFilled >= maxSlots) {
            return false;
          }

          transaction.update(docRef, <String, Object?>{
            'slots_filled': slotsFilled + 1,
          });

          return true;
        });
      } catch (e) {
        return false;
      }
    });
  }
}
