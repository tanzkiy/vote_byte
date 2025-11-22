## Diagnosis
- The error indicates a runtime type mismatch: an `IdentityMap<String, dynamic>` is reaching an API that requires `Map<String, Object?>` on web.
- Likely sources: `DatabaseHelper.submitVote`/`insertVote`, `AuthService.updateUserData`, and web fallback (`SimpleMockDatabase` / `SimpleMockTransaction`) signatures.
- Although several places were updated, the error persists, which suggests one path still passes `Map<String, dynamic>` to a method expecting `Map<String, Object?>`.

## Implementation Steps
1. Add lightweight runtime logs (guarded) to trace the exact path:
   - Log `runtimeType` and `is Map<String, Object?>` checks for `voteData` before `insert` and the payload for `updateUser`.
   - Log whether fallback mode is active when submitting votes.
2. Normalize all map types end‑to‑end to `Map<String, Object?>`:
   - Change `DatabaseHelper.submitVote` and `insertVote` to accept `Map<String, Object?>`.
   - In fallback, store `Map<String, Object?>.from(voteData)` instead of `Map<String, dynamic>.from(...)`.
   - Ensure `AuthService.updateUserData` constructs `Map<String, Object?>` and `DatabaseHelper.updateUser` converts appropriately.
   - Confirm `SimpleMockDatabase.update/insert` and `SimpleMockTransaction.update/insert` signatures use `Map<String, Object?>`.
3. Harden conversions:
   - Before `txn.insert('votes', ...)`, explicitly convert with `Map<String, Object?>.from(voteData)`.
   - For `update('users', ...)`, build `final updateData = <String, Object?>{'hasVoted': 1}`.
4. Fix any remaining callers:
   - `VotingService.submitVote` builds `final voteData = <String, Object?>{...}` and passes to `insertVote`.
   - Replace any inline `{'key': value}` maps used in DB calls with `<String, Object?>` typed maps.
5. Verify end‑to‑end:
   - Run on web, submit a vote for all positions, confirm success snackbar and updated results.
   - Test with “Abstain” to ensure empty strings are allowed and correctly stored.

## Deliverables
- Updated method signatures and conversions for web‑safe SQLite usage.
- Optional debug logging to pinpoint any remaining mismatches.
- Verified vote submission working on web without the IdentityMap TypeError.

## Request
- Confirm I should proceed with these changes and validations immediately.