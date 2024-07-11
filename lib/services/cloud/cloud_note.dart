import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:noteapp/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;
  final String title;
  final DateTime createdAt;

  const CloudNote(
      {required this.documentId,
      required this.ownerUserId,
      required this.text,
      required this.title,
      required this.createdAt});

  // Here we use a constructor to create a CloudNote from a QueryDocumentSnapshot that retrieves data from Firestore.
  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String,
        title = snapshot.data()[titleFieldName] as String,
        createdAt =
            (snapshot.data()[createdAtFieldName] as Timestamp?)?.toDate() ??
                DateTime.now();
}
