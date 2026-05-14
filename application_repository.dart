/*
 * Student Numbers: 224081110, 222001607, 222000452, 224065010, 221024286, 224067603, 224054263, 221046289, 222088478, 224013987
 * Student Names: M Lesenyeho, M Machedi, Z Sidamba, B Nakupi, H Sekethwayo, J O Molaba, K Semela, N Gumede, T Mjiyakho, K D Selebalo
 * Question: Application Repository (Data Layer - CRUD)
 */

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';
import '../core/constants/supabase_constants.dart';

class ApplicationRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // CREATE – submit a new application
  Future<ApplicationModel> createApplication(ApplicationModel app) async {
    final data = await _client
        .from(SupabaseConstants.applicationsTable)
        .insert(app.toMap())
        .select()
        .single();
    return ApplicationModel.fromMap(data);
  }

  // READ – fetch this student's applications
  Future<List<ApplicationModel>> getStudentApplications(String userId) async {
    final data = await _client
        .from(SupabaseConstants.applicationsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => ApplicationModel.fromMap(e)).toList();
  }

  // READ – fetch a single application
  Future<ApplicationModel?> getApplicationById(String id) async {
    final data = await _client
        .from(SupabaseConstants.applicationsTable)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return ApplicationModel.fromMap(data);
  }

  // UPDATE – edit a pending application
  Future<ApplicationModel> updateApplication(
      String id, Map<String, dynamic> updates) async {
    final data = await _client
        .from(SupabaseConstants.applicationsTable)
        .update({...updates, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .select()
        .single();
    return ApplicationModel.fromMap(data);
  }

  // DELETE – remove an application
  Future<void> deleteApplication(String id) async {
    await _client
        .from(SupabaseConstants.applicationsTable)
        .delete()
        .eq('id', id);
  }

  // ADMIN READ – fetch all applications
  Future<List<ApplicationModel>> getAllApplications({String? statusFilter}) async {
  dynamic query = _client
      .from(SupabaseConstants.applicationsTable)
      .select()
      .order('created_at', ascending: false);

  if (statusFilter != null && statusFilter != 'all') {
    query = query.eq('status', statusFilter);
  }

  final data = await query;
  return (data as List).map((e) => ApplicationModel.fromMap(e)).toList();
}

  // ADMIN UPDATE – approve or reject
  Future<void> updateApplicationStatus(String id, String status) async {
    await _client
        .from(SupabaseConstants.applicationsTable)
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  // Upload supporting document to Supabase Storage
  Future<String> uploadDocument(String userId, File file) async {
    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.pdf';
    await _client.storage
        .from(SupabaseConstants.documentsBucket)
        .upload(fileName, file);

    return _client.storage
        .from(SupabaseConstants.documentsBucket)
        .getPublicUrl(fileName);
  }

  // Check if a student already has an application
  Future<bool> hasExistingApplication(String userId) async {
    final data = await _client
        .from(SupabaseConstants.applicationsTable)
        .select('id')
        .eq('user_id', userId);
    return (data as List).isNotEmpty;
  }
}
