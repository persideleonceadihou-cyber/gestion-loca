/* eslint-disable no-undef */

importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBYWT7L2wcrpMCTPixjRo78Zx-CVt7y0IA',
  authDomain: 'sample-firebase-ai-app-g-96d78.firebaseapp.com',
  projectId: 'sample-firebase-ai-app-g-96d78',
  storageBucket: 'sample-firebase-ai-app-g-96d78.firebasestorage.app',
  messagingSenderId: '56626745106',
  appId: '1:56626745106:web:19e99bb3d72717a24c2dcb',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Background message received:', payload);
});
