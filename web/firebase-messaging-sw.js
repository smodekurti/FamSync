/* eslint-disable no-undef */
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyDCaEEBiXVFFx3HDSrZMS9l9xJ5PByVD4U',
  appId: '1:797333682643:web:6f0bf6c9cdbfabe6cad726',
  messagingSenderId: '797333682643',
  projectId: 'famsync-91f49',
  authDomain: 'famsync-91f49.firebaseapp.com',
  storageBucket: 'famsync-91f49.firebasestorage.app',
  measurementId: 'G-5ZB90DRYHH'
});

const messaging = firebase.messaging();
messaging.onBackgroundMessage((payload) => {
  const { title, body } = payload.notification || {};
  self.registration.showNotification(title || 'FamSync', { body });
});


