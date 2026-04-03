require('dotenv').config();

const cors = require('cors');
const express = require('express');
const { AccessToken } = require('livekit-server-sdk');

const app = express();
app.use(express.json({ limit: '128kb' }));

const corsOrigin = process.env.CORS_ORIGIN?.trim() || '*';
app.use(
  cors({
    origin: corsOrigin,
    methods: ['GET', 'POST', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'x-client-secret'],
  }),
);

const port = Number(process.env.PORT || 3000);
const livekitApiKey = process.env.LIVEKIT_API_KEY?.trim() || '';
const livekitApiSecret = process.env.LIVEKIT_API_SECRET?.trim() || '';
const livekitUrl = process.env.LIVEKIT_URL?.trim() || '';
const clientSharedSecret = process.env.CLIENT_SHARED_SECRET?.trim() || '';

function isConfigReady() {
  return (
    livekitApiKey.length > 0 && livekitApiSecret.length > 0 && livekitUrl.length > 0
  );
}

function normalizeText(value) {
  return (value ?? '').toString().trim();
}

function fail(res, status, code, message) {
  return res.status(status).json({ error: code, message });
}

function assertClientSecret(req, res) {
  if (!clientSharedSecret) {
    return true;
  }
  const got = normalizeText(req.header('x-client-secret'));
  if (got !== clientSharedSecret) {
    fail(res, 401, 'unauthorized', 'Invalid client secret');
    return false;
  }
  return true;
}

function validateRoomName(value) {
  // Keep room names safe and deterministic for logs and ACL checks.
  return /^[A-Za-z0-9._:-]{3,128}$/.test(value);
}

function validateParticipantId(value) {
  return /^[A-Za-z0-9._:@-]{2,128}$/.test(value);
}

app.get('/health', (_req, res) => {
  res.json({
    ok: true,
    configReady: isConfigReady(),
    livekitUrl: livekitUrl || null,
  });
});

app.post('/livekit/token', async (req, res) => {
  if (!isConfigReady()) {
    return fail(
      res,
      500,
      'server_not_configured',
      'LIVEKIT_API_KEY/LIVEKIT_API_SECRET/LIVEKIT_URL are required',
    );
  }
  if (!assertClientSecret(req, res)) {
    return;
  }

  const roomName = normalizeText(req.body?.roomName);
  const participantId = normalizeText(req.body?.participantId);
  const participantNameRaw = normalizeText(req.body?.participantName);
  const participantName = participantNameRaw || participantId;

  if (!validateRoomName(roomName)) {
    return fail(res, 400, 'invalid_room', 'roomName is invalid');
  }
  if (!validateParticipantId(participantId)) {
    return fail(
      res,
      400,
      'invalid_participant',
      'participantId is invalid',
    );
  }

  try {
    const token = new AccessToken(livekitApiKey, livekitApiSecret, {
      identity: participantId,
      name: participantName,
      ttl: '2h',
      metadata: JSON.stringify({
        sessionId: normalizeText(req.body?.sessionId),
      }),
    });

    token.addGrant({
      roomJoin: true,
      room: roomName,
      canPublish: true,
      canSubscribe: true,
      canPublishData: true,
    });

    const jwt = await token.toJwt();
    return res.json({
      url: livekitUrl,
      token: jwt,
      roomName,
      participantId,
    });
  } catch (error) {
    const message =
      error && typeof error.message === 'string'
        ? error.message
        : 'token_generation_failed';
    return fail(res, 500, 'token_generation_failed', message);
  }
});

app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(
    `[livekit-token-server] listening on :${port} (configReady=${isConfigReady()})`,
  );
});
