import 'package:gokgok/core/errors/app_exception.dart';
import 'package:gokgok/features/buzzer/data/datasources/buzzer_remote_data_source.dart';
import 'package:gokgok/features/buzzer/domain/entities/buzzer_sound.dart';
import 'package:gokgok/features/buzzer/domain/repositories/buzzer_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuzzerRepositoryImpl implements BuzzerRepository {
  BuzzerRepositoryImpl(this._remote);

  final BuzzerRemoteDataSource _remote;

  @override
  Future<List<BuzzerSound>> fetchSounds() async {
    try {
      final rows = await _remote.fetchActiveSounds();
      return rows.map(BuzzerSound.fromJson).toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    }
  }
}
