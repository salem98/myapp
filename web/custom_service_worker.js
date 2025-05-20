// Custom Service Worker for TNS Express PWA

const APP_VERSION = '1.0.4';
const CACHE_NAME = `tns-express-cache-${APP_VERSION}`;
const RESOURCES = [
  '/',
  '/index.html',
  '/offline.html',
  '/favicon.png',
  '/manifest.json',
  '/network_status.js',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png',
  // Add other assets that should be cached
];

// Offline fallback page
const OFFLINE_PAGE = '/offline.html';

// Install event - cache resources
self.addEventListener('install', (event) => {
  console.log('Service worker installing...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('Opened cache');
        return cache.addAll(RESOURCES);
      })
  );
  // Activate the new service worker immediately
  self.skipWaiting();
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  console.log('Service worker activating...');
  event.waitUntil(
    (async () => {
      const cacheNames = await caches.keys();
      for (const cacheName of cacheNames) {
        if (cacheName !== CACHE_NAME) {
          console.log('Deleting old cache:', cacheName);
          await caches.delete(cacheName);
        }
      }
      // Claim clients so the service worker is in control immediately
      await self.clients.claim();
      console.log('Service worker activated and clients claimed.');
    })()
  );
});

// Fetch event - serve from cache, fall back to network
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // Cache hit - return the response from the cached version
        if (response) {
          return response;
        }
        
        // Not in cache - fetch from network
        return fetch(event.request)
          .then((response) => {
            // Check if we received a valid response
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }

            // Clone the response
            const responseToCache = response.clone();

            // Add the response to the cache
            caches.open(CACHE_NAME)
              .then((cache) => {
                cache.put(event.request, responseToCache);
              });

            return response;
          })
          .catch(() => {
            // If both cache and network fail, show the offline page
            return caches.match(OFFLINE_PAGE);
          });
      })
  );
});

// Handle push notifications (if implemented)
self.addEventListener('push', (event) => {
  console.log('Push event received:', event);
  if (event.data) {
    const data = event.data.json();
    console.log('Push data:', data);
    
    const options = {
      body: data.body || 'New update from TNS Express',
      icon: '/icons/Icon-192.png',
      badge: '/icons/Icon-192.png',
      vibrate: [100, 50, 100],
      data: {
        url: data.url || '/'
      }
    };
    
    event.waitUntil(
      self.registration.showNotification(data.title || 'TNS Express', options)
    );
  }
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
  console.log('Notification click event:', event);
  event.notification.close();
  
  event.waitUntil(
    clients.openWindow(event.notification.data.url || '/')
  );
});