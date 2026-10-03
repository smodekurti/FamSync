/* eslint-disable no-undef */
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "REPLACE_APIKEY",
  appId: "REPLACE_APPID",
  messagingSenderId: "REPLACE_MESSAGINGSENDERID",
  projectId: "REPLACE_PROJECTID",
  authDomain: "REPLACE_AUTHDOMAIN",
  storageBucket: "REPLACE_STORAGEBUCKET",
  measurementId: "REPLACE_MEASUREMENTID"
});

const messaging = firebase.messaging();
messaging.onBackgroundMessage((payload) => {
  const { title, body } = payload.notification || {};
  self.registration.showNotification(title || 'FamSync', { body });
});


