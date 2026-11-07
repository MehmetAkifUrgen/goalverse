import 'package:firebase_auth/firebase_auth.dart';
import '../../../l10n/app_localizations.dart';

/// Maps FirebaseAuthException and authentication errors into user-friendly,
/// localized messages across all 6 supported languages (tr, en, es, fr, de, it).
class AuthErrorMapper {
  AuthErrorMapper._();

  /// Returns true if the exception represents a user-initiated cancellation
  /// (e.g. closing the Google or Apple account picker), which should not be
  /// shown as a red error banner.
  static bool isUserCanceled(Object error) {
    if (error is FirebaseAuthException) {
      return error.code == 'aborted' ||
          error.code == 'canceled' ||
          error.code == 'web-context-canceled' ||
          error.code == 'popup-closed-by-user';
    }
    return false;
  }

  static String mapException(Object error, AppLocalizations l10n) {
    final lang = l10n.localeName.split('_').first.toLowerCase();

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return l10n.errorInvalidEmail;
        case 'wrong-password':
          return l10n.errorWrongPassword;
        case 'invalid-credential':
        case 'INVALID_LOGIN_CREDENTIALS':
          return _localized(
            lang,
            tr: 'E-posta adresi veya şifre hatalı. Lütfen kontrol edip tekrar deneyin.',
            en: 'Incorrect email or password. Please check and try again.',
            es: 'Correo o contraseña incorrectos. Inténtalo de nuevo.',
            fr: 'E-mail ou mot de passe incorrect. Veuillez réessayer.',
            de: 'E-Mail oder Passwort ist falsch. Bitte erneut versuchen.',
            it: 'Email o password non corretti. Riprova.',
          );
        case 'user-not-found':
          return l10n.errorUserNotFound;
        case 'email-already-in-use':
        case 'credential-already-in-use':
          return l10n.errorEmailAlreadyInUse;
        case 'weak-password':
          return l10n.errorWeakPassword;
        case 'user-disabled':
          return l10n.errorUserDisabled;
        case 'operation-not-allowed':
          return l10n.errorOperationNotAllowed;
        case 'too-many-requests':
          return l10n.errorTooManyRequests;
        case 'network-request-failed':
          return l10n.errorNetwork;
        case 'account-exists-with-different-credential':
          return _localized(
            lang,
            tr: 'Bu e-posta adresi farklı bir giriş yöntemiyle (ör. Google veya E-posta) ilişkilendirilmiş.',
            en: 'An account already exists with the same email but different sign-in credentials.',
            es: 'Ya existe una cuenta con este correo pero con otro método de acceso.',
            fr: 'Un compte existe déjà avec cet e-mail via une autre méthode de connexion.',
            de: 'Für diese E-Mail existiert bereits ein Konto mit einer anderen Anmeldemethode.',
            it: 'Esiste già un account con questa email ma con un altro metodo di accesso.',
          );
        case 'requires-recent-login':
          return _localized(
            lang,
            tr: 'Güvenliğiniz için bu işlemden önce yeniden giriş yapmanız gerekiyor.',
            en: 'For your security, please sign in again before performing this action.',
            es: 'Por seguridad, vuelve a iniciar sesión antes de realizar esta acción.',
            fr: 'Par sécurité, veuillez vous reconnecter avant d\'effectuer cette action.',
            de: 'Aus Sicherheitsgründen melden Sie sich bitte erneut an.',
            it: 'Per sicurezza, effettua nuovamente l\'accesso prima di procedere.',
          );
        case 'google-play-services-unavailable':
          return _localized(
            lang,
            tr: 'Cihazda Google Play Hizmetleri kullanılamıyor veya güncel değil.',
            en: 'Google Play Services is unavailable or out of date on this device.',
            es: 'Google Play Services no está disponible o actualizado en este dispositivo.',
            fr: 'Les services Google Play ne sont pas disponibles sur cet appareil.',
            de: 'Google Play-Dienste sind auf diesem Gerät nicht verfügbar.',
            it: 'Google Play Services non è disponibile su questo dispositivo.',
          );
        case 'google-sign-in-config-error':
          return _localized(
            lang,
            tr: 'Google ile giriş yapılandırması doğrulanamadı (OAuth / SHA sertifikası). Lütfen tekrar deneyin.',
            en: 'Google Sign-In configuration error (OAuth / SHA certificate). Please try again.',
            es: 'Error de configuración de Google Sign-In (certificado OAuth / SHA).',
            fr: 'Erreur de configuration Google Sign-In (certificat OAuth / SHA).',
            de: 'Google Sign-In-Konfigurationsfehler (OAuth / SHA-Zertifikat).',
            it: 'Errore di configurazione Google Sign-In (certificato OAuth / SHA).',
          );
        case 'aborted':
        case 'canceled':
          return l10n.errorAborted;
        default:
          return l10n.errorUnknown;
      }
    }

    return l10n.errorUnknown;
  }

  static String _localized(
    String lang, {
    required String tr,
    required String en,
    required String es,
    required String fr,
    required String de,
    required String it,
  }) {
    switch (lang) {
      case 'tr':
        return tr;
      case 'es':
        return es;
      case 'fr':
        return fr;
      case 'de':
        return de;
      case 'it':
        return it;
      default:
        return en;
    }
  }
}
