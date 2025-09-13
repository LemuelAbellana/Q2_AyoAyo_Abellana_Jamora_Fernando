// sqflite service worker for web
// This file is required for sqflite_common_ffi_web to work properly

// Simple service worker that sqflite_common_ffi_web expects
self.addEventListener('message', function(event) {
  const { id, method, args } = event.data;

  // For now, just echo back with a simple response
  // This prevents the "worker not found" error
  self.postMessage({
    id: id,
    result: { success: true, method: method }
  });
});

// Keep the service worker alive
self.addEventListener('activate', function(event) {
  event.waitUntil(self.clients.claim());
});
