import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../core/db/local_database.dart';
import '../../auth/repository/auth_repository.dart';
import '../controller/diary_controller.dart';
import 'diary_repository.dart';

class SyncRepository {
  final LocalDatabase _db;
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  SyncRepository(this._db, this._firestore, this._auth);

  String _getQuestionKey(int questionNumber, String title) {
    final padNum = questionNumber.toString().padLeft(2, '0');
    final cleanTitle = title.toLowerCase()
        .replaceAll(' & ', '_')
        .replaceAll(' ', '_')
        .replaceAll("'", '_')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('à', 'a');
    return "q${padNum}_$cleanTitle";
  }

  List<int> _parseValues(String valStr) {
    if (valStr.trim().isEmpty) return [];
    return valStr.split(',').map((e) => int.tryParse(e) ?? 0).toList();
  }

  Map<String, dynamic> _serializeResponses(List<DiaryResponse> responses) {
    final Map<String, dynamic> result = {};
    for (final r in responses) {
      final question = diaryQuestionsList.firstWhere(
        (q) => q.number == r.questionNumber,
        orElse: () => DiaryQuestion(
          number: r.questionNumber,
          category: '',
          title: 'q${r.questionNumber}',
          description: '',
        ),
      );

      final key = _getQuestionKey(r.questionNumber, question.title);
      result[key] = {
        'nuit': _parseValues(r.nuitValues),
        'nuit_comment': r.nuitComment,
        'matin': _parseValues(r.matinValues),
        'matin_comment': r.matinComment,
        'journee': _parseValues(r.journeeValues),
        'journee_comment': r.journeeComment,
        'soir': _parseValues(r.soirValues),
        'soir_comment': r.soirComment,
      };
    }
    return result;
  }

  List<DiaryResponsesCompanion> _deserializeResponses(
    String diaryDayId,
    Map<String, dynamic> firestoreResponses,
  ) {
    final List<DiaryResponsesCompanion> companions = [];
    firestoreResponses.forEach((key, value) {
      final match = RegExp(r'^q(\d+)').firstMatch(key);
      if (match != null) {
        final qNumber = int.parse(match.group(1)!);
        final Map<dynamic, dynamic> map = value is Map ? value : {};
        
        final List<dynamic> nuit = map['nuit'] ?? [];
        final List<dynamic> matin = map['matin'] ?? [];
        final List<dynamic> journee = map['journee'] ?? [];
        final List<dynamic> soir = map['soir'] ?? [];
        
        final String nuitComment = map['nuit_comment'] as String? ?? '';
        final String matinComment = map['matin_comment'] as String? ?? '';
        final String journeeComment = map['journee_comment'] as String? ?? '';
        final String soirComment = map['soir_comment'] as String? ?? '';

        companions.add(DiaryResponsesCompanion(
          id: Value('${diaryDayId}_$qNumber'),
          diaryDayId: Value(diaryDayId),
          questionNumber: Value(qNumber),
          nuitValues: Value(nuit.join(',')),
          matinValues: Value(matin.join(',')),
          journeeValues: Value(journee.join(',')),
          soirValues: Value(soir.join(',')),
          nuitComment: Value(nuitComment),
          matinComment: Value(matinComment),
          journeeComment: Value(journeeComment),
          soirComment: Value(soirComment),
          updatedAt: Value(DateTime.now()),
        ));
      }
    });
    return companions;
  }

  // Helper to sync a single day to/from Firestore
  Future<void> syncDay(String date) async {
    if (_auth == null || _firestore == null) return;
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid).collection('diary_days').doc(date);
    
    // Get local day
    final localDay = await (_db.select(_db.diaryDays)..where((tbl) => tbl.date.equals(date))).getSingleOrNull();
    
    // Get remote day
    final remoteSnapshot = await docRef.get();
    
    if (localDay == null && !remoteSnapshot.exists) {
      return;
    }

    if (localDay == null && remoteSnapshot.exists) {
      // Pull remote to local
      await _pullRemoteToLocal(date, remoteSnapshot);
      return;
    }

    if (localDay != null && !remoteSnapshot.exists) {
      // Push local to remote
      await _pushLocalToRemote(localDay, docRef);
      return;
    }

    if (localDay != null && remoteSnapshot.exists) {
      final remoteData = remoteSnapshot.data()!;
      final remoteUpdatedAt = (remoteData['updated_at'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
      final localUpdatedAt = localDay.updatedAt;

      if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
        await _pullRemoteToLocal(date, remoteSnapshot);
      } else if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
        await _pushLocalToRemote(localDay, docRef);
      }
    }
  }

  // Two-way synchronization of all records
  Future<void> syncAll() async {
    if (_auth == null || _firestore == null) return;
    final user = _auth.currentUser;
    if (user == null) return;

    debugPrint("Starting full diary sync for user: ${user.uid}");

    try {
      final querySnapshot = await _firestore.collection('users').doc(user.uid).collection('diary_days').get();
      final localDays = await _db.select(_db.diaryDays).get();

      final Map<String, DocumentSnapshot> remoteDaysMap = {
        for (var doc in querySnapshot.docs) doc.id: doc
      };
      
      final Map<String, DiaryDay> localDaysMap = {
        for (var d in localDays) d.date: d
      };

      // 1. Process all remote days
      for (final date in remoteDaysMap.keys) {
        final remoteDoc = remoteDaysMap[date]!;
        final localDay = localDaysMap[date];

        if (localDay == null) {
          await _pullRemoteToLocal(date, remoteDoc);
        } else {
          final remoteData = remoteDoc.data() as Map<String, dynamic>;
          final remoteUpdatedAt = (remoteData['updated_at'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
          final localUpdatedAt = localDay.updatedAt;

          if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
            await _pullRemoteToLocal(date, remoteDoc);
          } else if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
            await _pushLocalToRemote(localDay, _firestore.collection('users').doc(user.uid).collection('diary_days').doc(date));
          }
        }
      }

      // 2. Process local days not in remote
      for (final date in localDaysMap.keys) {
        if (!remoteDaysMap.containsKey(date)) {
          final localDay = localDaysMap[date]!;
          await _pushLocalToRemote(localDay, _firestore.collection('users').doc(user.uid).collection('diary_days').doc(date));
        }
      }
      
      debugPrint("Full sync completed successfully.");
    } catch (e) {
      debugPrint("Sync failed: $e");
    }
  }

  Future<void> _pushLocalToRemote(DiaryDay localDay, DocumentReference docRef) async {
    final responses = await (_db.select(_db.diaryResponses)..where((tbl) => tbl.diaryDayId.equals(localDay.id))).get();
    
    final data = {
      'date': localDay.date,
      'status': localDay.status,
      'scores': {
        'total': localDay.totalScore,
        'mean': localDay.meanScore,
        'median': localDay.medianScore,
        'level': localDay.level,
      },
      'insight_text': localDay.insightText,
      'responses': _serializeResponses(responses),
      'created_at': Timestamp.fromDate(localDay.createdAt),
      'updated_at': Timestamp.fromDate(localDay.updatedAt),
    };

    await docRef.set(data, SetOptions(merge: true));
    
    // Update local syncedAt timestamp
    await (_db.update(_db.diaryDays)..where((tbl) => tbl.id.equals(localDay.id)))
        .write(DiaryDaysCompanion(syncedAt: Value(DateTime.now())));
  }

  Future<void> _pullRemoteToLocal(String date, DocumentSnapshot docSnapshot) async {
    final data = docSnapshot.data() as Map<String, dynamic>?;
    if (data == null) return;

    final scores = data['scores'] as Map<dynamic, dynamic>? ?? {};
    final status = data['status'] as String? ?? 'draft';
    final insight = data['insight_text'] as String?;
    final createdAt = (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
    final updatedAt = (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now();

    final dayCompanion = DiaryDaysCompanion(
      id: Value(date), // use date as ID for pulled entries to guarantee uniqueness
      date: Value(date),
      status: Value(status),
      totalScore: Value((scores['total'] as num?)?.toDouble() ?? 0.0),
      meanScore: Value((scores['mean'] as num?)?.toDouble() ?? 0.0),
      medianScore: Value((scores['median'] as num?)?.toDouble() ?? 0.0),
      level: Value(scores['level'] as String? ?? 'Moyen'),
      insightText: Value(insight),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(DateTime.now()),
    );

    // Insert or update day
    await _db.into(_db.diaryDays).insertOnConflictUpdate(dayCompanion);

    // Deserialize and insert responses
    final remoteResponses = data['responses'] as Map<String, dynamic>? ?? {};
    final companions = _deserializeResponses(date, remoteResponses);

    for (final companion in companions) {
      await _db.into(_db.diaryResponses).insertOnConflictUpdate(companion);
    }
  }

  // Delete day locally and remotely
  Future<void> deleteDay(String date) async {
    await (_db.delete(_db.diaryDays)..where((tbl) => tbl.date.equals(date))).go();
    
    if (_auth == null || _firestore == null) return;
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      final docRef = _firestore!.collection('users').doc(user.uid).collection('diary_days').doc(date);
      await docRef.delete();
      debugPrint("Deleted day $date from Firestore.");
    } catch (e) {
      debugPrint("Failed to delete day $date from Firestore: $e");
    }
  }
}

// Providers
final firestoreProvider = Provider<FirebaseFirestore?>((ref) {
  if (AuthRepository.forceMock) return null;
  try {
    Firebase.app();
    return FirebaseFirestore.instance;
  } catch (_) {
    return null;
  }
});

final firebaseAuthProvider = Provider<FirebaseAuth?>((ref) {
  if (AuthRepository.forceMock) return null;
  try {
    Firebase.app();
    return FirebaseAuth.instance;
  } catch (_) {
    return null;
  }
});

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return SyncRepository(db, firestore, auth);
});
