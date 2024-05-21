importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "xxx",
    authDomain: "minesort.firebaseapp.com",
    projectId: "minesort",
    storageBucket: "minesort.appspot.com",
    messagingSenderId: "xxx",
    appId: "xxx"
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});