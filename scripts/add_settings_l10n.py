import json
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent / "lib" / "l10n"

NEW_KEYS = {
    "difficultyAndControls": {
        "en": "Difficulty & Controls",
        "tr": "Zorluk ve Kontroller",
        "de": "Schwierigkeit & Steuerung",
        "es": "Dificultad y Controles",
        "fr": "Difficulté et Contrôles",
        "it": "Difficoltà e Controlli",
        "desc": "Settings section header for difficulty and controls",
    },
    "turnDurationAndMultiplier": {
        "en": "Time: {seconds}s • Multiplier: {multiplier}x",
        "tr": "Süre: {seconds}sn • Çarpan: {multiplier}x",
        "de": "Zeit: {seconds}s • Multiplikator: {multiplier}x",
        "es": "Tiempo: {seconds}s • Multiplicador: {multiplier}x",
        "fr": "Temps : {seconds}s • Multiplicateur : {multiplier}x",
        "it": "Tempo: {seconds}s • Moltiplicatore: {multiplier}x",
        "desc": "Settings indicator for turn duration and score multiplier",
        "placeholders": {
            "seconds": {"type": "int"},
            "multiplier": {"type": "String"},
        },
    },
    "hapticsTitle": {
        "en": "Haptic Feedback (Vibration)",
        "tr": "Titreşim (Haptic Geri Bildirim)",
        "de": "Haptisches Feedback (Vibration)",
        "es": "Respuesta Háptica (Vibración)",
        "fr": "Retour Haptique (Vibration)",
        "it": "Feedback Aptico (Vibrazione)",
        "desc": "Settings switch title for vibration",
    },
    "hapticsSubtitle": {
        "en": "Tactile feedback on correct and wrong guesses",
        "tr": "Doğru ve yanlış tahminlerde dokunsal geri bildirim",
        "de": "Taktiles Feedback bei richtigen und falschen Tipps",
        "es": "Respuesta táctil en aciertos y fallos",
        "fr": "Retour tactile lors des bonnes et mauvaises réponses",
        "it": "Feedback tattile su risposte corrette ed errate",
        "desc": "Settings switch subtitle for vibration",
    },
    "soundEffectsTitle": {
        "en": "Sound Effects",
        "tr": "Ses Efektleri",
        "de": "Soundeffekte",
        "es": "Efectos de Sonido",
        "fr": "Effets Sonores",
        "it": "Effetti Sonori",
        "desc": "Settings switch title for audio",
    },
    "soundEffectsSubtitle": {
        "en": "Stadium atmosphere and in-game sound effects",
        "tr": "Stadyum ve maç içi ses efektleri",
        "de": "Stadionatmosphäre und Sounds im Spiel",
        "es": "Ambiente de estadio y efectos en el partido",
        "fr": "Ambiance de stade et bruitages en jeu",
        "it": "Atmosfera dello stadio ed effetti di gioco",
        "desc": "Settings switch subtitle for audio",
    },
    "sendPasswordResetLink": {
        "en": "Send Password Reset Link",
        "tr": "Şifre Sıfırlama Bağlantısı Gönder",
        "de": "Passwort-Reset-Link senden",
        "es": "Enviar enlace para restablecer contraseña",
        "fr": "Envoyer le lien de réinitialisation",
        "it": "Invia link per reimpostare la password",
        "desc": "Settings account tile to send reset email",
    },
    "deleteAccountPermanently": {
        "en": "Delete Account Permanently",
        "tr": "Hesabı Kalıcı Olarak Sil",
        "de": "Konto dauerhaft löschen",
        "es": "Eliminar cuenta permanentemente",
        "fr": "Supprimer définitivement le compte",
        "it": "Elimina definitivamente l'account",
        "desc": "Settings danger zone tile",
    },
    "deleteAccountSubtitle": {
        "en": "Permanently erase your profile data and account",
        "tr": "Profil verilerinizi ve hesabınızı kalıcı olarak siler",
        "de": "Löscht deine Profildaten und dein Konto unwiderruflich",
        "es": "Elimina de forma permanente tus datos y tu cuenta",
        "fr": "Supprime définitivement vos données de profil et votre compte",
        "it": "Elimina definitivamente il tuo profilo e il tuo account",
        "desc": "Settings danger zone subtitle",
    },
    "deleteAccountWarning": {
        "en": "This action cannot be undone. Your ELO rating, match history, and user profile will be permanently erased.",
        "tr": "Bu işlem geri alınamaz. ELO puanınız, galibiyet geçmişiniz ve kullanıcı profiliniz kalıcı olarak silinecektir.",
        "de": "Diese Aktion kann nicht rückgängig gemacht werden. Deine ELO-Punkte, Spielhistorie und dein Profil werden gelöscht.",
        "es": "Esta acción no se puede deshacer. Tu puntuación ELO, historial de partidos y perfil serán eliminados.",
        "fr": "Cette action est irréversible. Vos points ELO, historique de matchs et profil seront supprimés.",
        "it": "Questa azione non può essere annullata. Il tuo punteggio ELO, cronologia partite e profilo saranno cancellati.",
        "desc": "Delete account confirmation dialog warning message",
    },
    "currentPasswordPrompt": {
        "en": "Enter your current password to confirm",
        "tr": "Onay için mevcut şifrenizi girin",
        "de": "Gib zur Bestätigung dein aktuelles Passwort ein",
        "es": "Introduce tu contraseña actual para confirmar",
        "fr": "Entrez votre mot de passe actuel pour confirmer",
        "it": "Inserisci la tua password attuale per confermare",
        "desc": "Password confirmation input hint",
    },
    "pleaseEnterPassword": {
        "en": "Please enter your current password.",
        "tr": "Lütfen mevcut şifrenizi girin.",
        "de": "Bitte gib dein aktuelles Passwort ein.",
        "es": "Por favor, introduce tu contraseña actual.",
        "fr": "Veuillez entrer votre mot de passe actuel.",
        "it": "Per favore inserisci la tua password attuale.",
        "desc": "Validation error for empty password in account deletion",
    },
    "deleteAccountButton": {
        "en": "Delete Account",
        "tr": "Hesabı Sil",
        "de": "Konto löschen",
        "es": "Eliminar Cuenta",
        "fr": "Supprimer le Compte",
        "it": "Elimina Account",
        "desc": "Account deletion confirm action button",
    },
    "deletingAccount": {
        "en": "Deleting...",
        "tr": "Siliniyor...",
        "de": "Wird gelöscht...",
        "es": "Eliminando...",
        "fr": "Suppression...",
        "it": "Eliminazione...",
        "desc": "Account deletion progress indicator text",
    },
}

def update_arb(lang: str):
    path = BASE_DIR / f"app_{lang}.arb"
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    for k, v in NEW_KEYS.items():
        data[k] = v[lang]
        if lang == "en":
            meta = {"description": v["desc"]}
            if "placeholders" in v:
                meta["placeholders"] = v["placeholders"]
            data[f"@{k}"] = meta

    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Updated {path.name}")

for lang in ["en", "tr", "de", "es", "fr", "it"]:
    update_arb(lang)

