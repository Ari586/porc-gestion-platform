#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f ".env.turn" ]]; then
  # shellcheck disable=SC1091
  source ".env.turn"
fi

PROJECT_ID="${PROJECT_ID:-porc-gestion-platform}"
WEBRTC_FORCE_RELAY="${WEBRTC_FORCE_RELAY:-true}"
CALL_TRANSPORT="${CALL_TRANSPORT:-webrtc}"

if [[ "${CALL_TRANSPORT}" == "webrtc" ]]; then
  : "${WEBRTC_TURN_URLS:?Missing WEBRTC_TURN_URLS}"
  : "${WEBRTC_TURN_USERNAME:?Missing WEBRTC_TURN_USERNAME}"
  : "${WEBRTC_TURN_CREDENTIAL:?Missing WEBRTC_TURN_CREDENTIAL}"
elif [[ "${CALL_TRANSPORT}" == "livekit" ]]; then
  : "${LIVEKIT_TOKEN_ENDPOINT:?Missing LIVEKIT_TOKEN_ENDPOINT when CALL_TRANSPORT=livekit}"
else
  echo "Unsupported CALL_TRANSPORT='${CALL_TRANSPORT}' (expected 'webrtc' or 'livekit')."
  exit 1
fi

BUILD_ARGS=(
  "build"
  "web"
  "--no-wasm-dry-run"
  "--pwa-strategy=none"
  "--dart-define=CALL_TRANSPORT=${CALL_TRANSPORT}"
  "--dart-define=WEBRTC_FORCE_RELAY=${WEBRTC_FORCE_RELAY}"
)

if [[ -n "${WEBRTC_TURN_URLS:-}" ]]; then
  BUILD_ARGS+=("--dart-define=WEBRTC_TURN_URLS=${WEBRTC_TURN_URLS}")
fi
if [[ -n "${WEBRTC_TURN_USERNAME:-}" ]]; then
  BUILD_ARGS+=("--dart-define=WEBRTC_TURN_USERNAME=${WEBRTC_TURN_USERNAME}")
fi
if [[ -n "${WEBRTC_TURN_CREDENTIAL:-}" ]]; then
  BUILD_ARGS+=("--dart-define=WEBRTC_TURN_CREDENTIAL=${WEBRTC_TURN_CREDENTIAL}")
fi

if [[ -n "${WEBRTC_STUN_URLS:-}" ]]; then
  BUILD_ARGS+=("--dart-define=WEBRTC_STUN_URLS=${WEBRTC_STUN_URLS}")
fi

if [[ -n "${WEBRTC_TURN_URLS_2:-}" ]]; then
  BUILD_ARGS+=("--dart-define=WEBRTC_TURN_URLS_2=${WEBRTC_TURN_URLS_2}")
fi
if [[ -n "${WEBRTC_TURN_USERNAME_2:-}" ]]; then
  BUILD_ARGS+=("--dart-define=WEBRTC_TURN_USERNAME_2=${WEBRTC_TURN_USERNAME_2}")
fi
if [[ -n "${WEBRTC_TURN_CREDENTIAL_2:-}" ]]; then
  BUILD_ARGS+=("--dart-define=WEBRTC_TURN_CREDENTIAL_2=${WEBRTC_TURN_CREDENTIAL_2}")
fi
if [[ -n "${WEBRTC_TURN_URLS_3:-}" ]]; then
  BUILD_ARGS+=("--dart-define=WEBRTC_TURN_URLS_3=${WEBRTC_TURN_URLS_3}")
fi
if [[ -n "${WEBRTC_TURN_USERNAME_3:-}" ]]; then
  BUILD_ARGS+=("--dart-define=WEBRTC_TURN_USERNAME_3=${WEBRTC_TURN_USERNAME_3}")
fi
if [[ -n "${WEBRTC_TURN_CREDENTIAL_3:-}" ]]; then
  BUILD_ARGS+=("--dart-define=WEBRTC_TURN_CREDENTIAL_3=${WEBRTC_TURN_CREDENTIAL_3}")
fi

if [[ -n "${LIVEKIT_TOKEN_ENDPOINT:-}" ]]; then
  BUILD_ARGS+=("--dart-define=LIVEKIT_TOKEN_ENDPOINT=${LIVEKIT_TOKEN_ENDPOINT}")
fi
if [[ -n "${LIVEKIT_URL:-}" ]]; then
  BUILD_ARGS+=("--dart-define=LIVEKIT_URL=${LIVEKIT_URL}")
fi
if [[ -n "${LIVEKIT_CLIENT_SECRET:-}" ]]; then
  BUILD_ARGS+=("--dart-define=LIVEKIT_CLIENT_SECRET=${LIVEKIT_CLIENT_SECRET}")
fi
if [[ -n "${FIREBASE_API_KEY:-}" ]]; then
  BUILD_ARGS+=("--dart-define=FIREBASE_API_KEY=${FIREBASE_API_KEY}")
fi
if [[ -n "${FIREBASE_APP_ID:-}" ]]; then
  BUILD_ARGS+=("--dart-define=FIREBASE_APP_ID=${FIREBASE_APP_ID}")
fi
if [[ -n "${FIREBASE_PROJECT_ID:-}" ]]; then
  BUILD_ARGS+=("--dart-define=FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID}")
fi
if [[ -n "${FIREBASE_MESSAGING_SENDER_ID:-}" ]]; then
  BUILD_ARGS+=("--dart-define=FIREBASE_MESSAGING_SENDER_ID=${FIREBASE_MESSAGING_SENDER_ID}")
fi
if [[ -n "${FIREBASE_AUTH_DOMAIN:-}" ]]; then
  BUILD_ARGS+=("--dart-define=FIREBASE_AUTH_DOMAIN=${FIREBASE_AUTH_DOMAIN}")
fi
if [[ -n "${FIREBASE_STORAGE_BUCKET:-}" ]]; then
  BUILD_ARGS+=("--dart-define=FIREBASE_STORAGE_BUCKET=${FIREBASE_STORAGE_BUCKET}")
fi
if [[ -n "${FIREBASE_DATABASE_URL:-}" ]]; then
  BUILD_ARGS+=("--dart-define=FIREBASE_DATABASE_URL=${FIREBASE_DATABASE_URL}")
fi
if [[ -n "${FIREBASE_MEASUREMENT_ID:-}" ]]; then
  BUILD_ARGS+=("--dart-define=FIREBASE_MEASUREMENT_ID=${FIREBASE_MEASUREMENT_ID}")
fi
if [[ -n "${FIREBASE_WEB_PUSH_VAPID_KEY:-}" ]]; then
  BUILD_ARGS+=("--dart-define=FIREBASE_WEB_PUSH_VAPID_KEY=${FIREBASE_WEB_PUSH_VAPID_KEY}")
fi

echo "Building web app with TURN relay config..."
flutter "${BUILD_ARGS[@]}"

echo "Deploying to Firebase Hosting project: ${PROJECT_ID}"
firebase deploy --project "${PROJECT_ID}" --only hosting

echo "Done. Hosting URL: https://${PROJECT_ID}.web.app"
