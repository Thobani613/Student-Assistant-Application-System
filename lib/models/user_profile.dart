/*
 * Student Numbers: 224081110, 222001607, 222000452, 224065010, 221024286, 224067603, 224054263, 221046289, 222088478, 224013987
 * Student Names: M Lesenyeho, M Machedi, Z Sidamba, B Nakupi, H Sekethwayo, J O Molaba, K Semela, N Gumede, T Mjiyakho, K D Selebalo 
 * Question: User / Profile Model
 */

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String studentNumber;
  final String role; // 'student' | 'admin'

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.studentNumber,
    required this.role,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      email: map['email'] ?? '',
      fullName: map['full_name'] ?? '',
      studentNumber: map['student_number'] ?? '',
      role: map['role'] ?? 'student',
    );
  }

  bool get isAdmin => role == 'admin';
}
