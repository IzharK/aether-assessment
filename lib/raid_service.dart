import 'package:cloud_firestore/cloud_firestore.dart';

class RaidService {
  final FirebaseFirestore firestore;

  RaidService({required this.firestore});

  Future<bool> joinRaid({required String userId}) async {
    // TODO: Implement concurrency lock utilizing Firestore Transactions
    return false;
  }
}
