# TNS Express PWA Deployment Guide

This guide provides step-by-step instructions for building and deploying your TNS Express application as a Progressive Web App (PWA).

## What is a PWA?

A Progressive Web App (PWA) is a type of application that combines the best features of web and mobile apps. PWAs are:

- **Installable** - Users can add your app to their home screen
- **Reliable** - Works offline or with poor network conditions
- **Fast** - Loads quickly and responds to user interactions promptly
- **Engaging** - Can send push notifications and provide a full-screen experience

## Prerequisites

- Flutter SDK (latest stable version)
- Web development enabled in Flutter
- A hosting service that supports HTTPS (required for PWAs)

## Building Your PWA

### 1. Enable Flutter Web Support

If you haven't already enabled web support in Flutter, run:

```bash
flutter channel stable
flutter upgrade
flutter config --enable-web
```

### 2. Build the Web App with PWA Support

```bash
# Navigate to your project directory
cd /path/to/your/project

# Build the web app with PWA optimizations
flutter build web --web-renderer canvaskit --release --pwa-strategy offline-first
```

The `--pwa-strategy offline-first` flag is crucial as it generates the service worker with offline capabilities.

### 3. Test Your PWA Locally

Before deploying, test your PWA locally:

```bash
# Install a simple web server if you don't have one
npm install -g http-server

# Navigate to your build directory
cd build/web

# Start the server
http-server -p 8000
```

Open Chrome and navigate to `http://localhost:8000`

### 4. Verify PWA Features

Use Chrome DevTools (F12) to:

1. Go to the "Application" tab
2. Check "Service Workers" to verify registration
3. Check "Manifest" to verify it's loaded correctly
4. Test offline functionality by toggling "Offline" in the Network tab
5. Try installing the app using the install icon in the address bar

## Deploying Your PWA

### Option 1: Firebase Hosting (Recommended)

Firebase Hosting is well-suited for Flutter web apps and PWAs.

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project
firebase init hosting

# When prompted:
# - Select "build/web" as your public directory
# - Configure as a single-page app: Yes
# - Set up automatic builds and deploys with GitHub: Optional

# Deploy to Firebase
firebase deploy
```

### Option 2: GitHub Pages

1. Create a GitHub repository for your project
2. Push your `build/web` directory to the repository
3. Enable GitHub Pages in the repository settings
4. Set the source to the branch and folder containing your `build/web` files

### Option 3: Netlify

1. Create a Netlify account
2. Create a new site from Git or drag and drop your `build/web` directory
3. Configure your domain settings if needed

## Advanced PWA Features

### Push Notifications

To implement push notifications:

1. Set up a Firebase Cloud Messaging (FCM) project
2. Implement the necessary code to request notification permissions
3. Configure your service worker to handle push events

### Background Sync

For operations that need to work offline and sync later:

1. Use the Background Sync API in your service worker
2. Queue failed requests when offline
3. Process the queue when the user comes back online

## Troubleshooting

### Service Worker Issues

If your service worker isn't working correctly:

1. Check the "Application" > "Service Workers" tab in Chrome DevTools
2. Look for errors in the Console
3. Try unregistering the service worker and reloading

### Manifest Issues

If your app isn't installable:

1. Verify your manifest.json has all required fields
2. Check that icons are available in the correct sizes
3. Ensure your app is served over HTTPS

### Caching Issues

If content isn't available offline:

1. Check that your service worker is caching the correct files
2. Verify the cache storage in Chrome DevTools
3. Test by toggling offline mode in DevTools

## Resources

- [Flutter Web Documentation](https://flutter.dev/docs/deployment/web)
- [Google PWA Documentation](https://web.dev/progressive-web-apps/)
- [Lighthouse PWA Audits](https://developers.google.com/web/tools/lighthouse)
- [PWA Builder](https://www.pwabuilder.com/) - Tool to help optimize your PWA

## Next Steps

Consider these enhancements for your PWA:

1. Implement analytics to track user engagement
2. Add offline data synchronization
3. Optimize performance with lazy loading and code splitting
4. Implement push notifications for user engagement