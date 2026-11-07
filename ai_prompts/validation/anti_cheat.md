# ANTI-CHEAT ARCHITECTURE & PROTOCOL

You are the security engineer designing anti-cheat mechanisms for mobile football multiplayer trivia.

## 1. THREAT VECTORS
1. **Network Sniffing:** Inspecting incoming JSON payloads to read hidden answers before guessing.
   - *Mitigation:* Never send the answer or full candidate list to the client. The client sends a `playerId` guess, and the Cloud Function returns `{ valid: true/false }`.
2. **Automated Bots / OCR / Auto-Typer:** Fast scripted queries querying Google/ChatGPT within 500ms.
   - *Mitigation:*
     - Minimum human reaction time threshold (guesses under 800ms are flagged for rate-limiting).
     - Obfuscated UI element names.
     - Exponential backoff / cooldown on rapid incorrect guesses.
3. **Timer Tampering:** Modifying local device time to prolong turns.
   - *Mitigation:* Server-side deadlines using `admin.firestore.Timestamp` stored on game creation. Client-side timers are strictly cosmetic.
