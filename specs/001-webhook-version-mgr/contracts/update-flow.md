# Update Script Contract

The update flow is triggered by `make update` or the `scripts/update-webhook.sh`
script directly.

## Flow

```
1. Check prerequisites (curl, sha256sum, jq)
2. Read version.txt → current_version
3. Check cache (.cache/latest-release.json)
   ├── Cache hit & fresh (< 1h old) → use cached version
   └── Cache miss/stale → fetch from GitHub API
4. Compare current_version vs latest_version
   ├── Same → print "Already up to date (v{latest})", exit 0
   └── Different → continue
5. Download tarball + checksum file from GitHub Releases
6. Verify tarball SHA256 against checksum file
   ├── Match → extract binary to bin/webhook
   └── Mismatch → remove partial files, exit 2
7. Back up current bin/webhook → bin/webhook.previous
8. Move new binary to bin/webhook
9. Write latest_version to version.txt
10. Print "Updated to v{latest} (previous: v{current})"
```

## State Transitions

```
bin/webhook absent:
  download → verify → install → version.txt updated

bin/webhook present & outdated:
  download → verify → backup (.previous) → install → version.txt updated

bin/webhook present & current:
  skip (version.txt matches latest)

Checksum mismatch:
  abort → partial files removed → version.txt unchanged → binary unchanged

Network failure:
  → if cache available → use cache and report staleness
  → if no cache → error, exit 1
```
