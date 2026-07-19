# CI/CD

This Flutter project has two GitHub Actions workflows:

- `CI`: runs on pushes and pull requests, installs dependencies, analyzes, tests, and builds web when available.
- `Release`: manual workflow for web artifacts, signed Android App Bundles, optional Google Play internal upload, and optional iOS TestFlight upload.

## Android secrets

Set these repository secrets in GitHub:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`

The local generated values are stored outside Git in `~/Desktop/cicd-secrets`.

## iOS secrets

Set these repository secrets in GitHub when you want TestFlight automation:

- `ASC_KEY_ID`
- `ASC_ISSUER_ID`
- `ASC_PRIVATE_KEY`
- `APPLE_CERTIFICATE_P12_BASE64`
- `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_PROVISIONING_PROFILE_BASE64`

Before iOS can upload, the Apple Developer Program License Agreement must be accepted and the bundle ID, distribution certificate, and provisioning profile must exist in Apple Developer/App Store Connect.

## Local commands

Android local release:

```bash
./scripts/release_android_internal.sh
```

iOS local TestFlight upload from your Mac:

```bash
export ASC_KEY_ID="..."
export ASC_ISSUER_ID="..."
export ASC_PRIVATE_KEY="$(cat /path/to/AuthKey_XXXX.p8)"
./scripts/release_ios_testflight.sh
```
