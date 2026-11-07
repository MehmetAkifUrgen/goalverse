import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const AppUser._();

  const factory AppUser({
    required String uid,
    String? displayName,
    String? email,
    String? photoUrl,
    required bool isAnonymous,
    @Default(false) bool emailVerified,
    @Default('anonymous') String providerId,
  }) = _AppUser;

  /// Only email/password accounts that have not yet verified their email
  /// require the email verification step. Google, Apple, and Guest accounts
  /// do not require manual email verification.
  bool get requiresEmailVerification =>
      !isAnonymous && providerId == 'password' && !emailVerified;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
