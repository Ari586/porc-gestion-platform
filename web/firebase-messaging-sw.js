self.addEventListener('install', (event) => {
  event.waitUntil(self.skipWaiting());
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('push', (event) => {
  if (!event.data) {
    return;
  }
  let payload = {};
  try {
    payload = event.data.json();
  } catch (_) {
    payload = { title: 'PigIA', body: event.data.text() };
  }
  const title = payload?.notification?.title || payload?.title || 'PigIA';
  const body = payload?.notification?.body || payload?.body || '';
  const options = {
    body,
    data: payload?.data || payload || {},
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: payload?.data?.sessionId || payload?.sessionId || 'pigia-notif',
  };
  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(
      (clientList) => {
        for (const client of clientList) {
          if ('focus' in client) {
            return client.focus();
          }
        }
        if (self.clients.openWindow) {
          return self.clients.openWindow('/');
        }
        return null;
      },
    ),
  );
});
