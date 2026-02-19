# Flutter Chat App using Firebase
**Group No. 01**

Flutter Firebase Chat App  is a real-time cross-platform mobile chat application developed using Flutter and Firebase, built to showcase how modern cloud technologies can be used to create a secure, scalable, and responsive messaging system. The app supports user authentication, instant real-time messaging, and push notifications, ensuring users can communicate seamlessly with low-latency updates across devices. This project demonstrates practical implementation of Firebase services for backend management, real-time data synchronization, and secure user handling in a modern Flutter mobile application.

## GROUP MEMBERS
| S/N | Username           | Full Name           | Registration Number      |
|-----|------------------|-------------------|-------------------------|
| 1   | DARSTORE17        | David Daniel Makuri | NIT/BIT/2023/2305       |
| 2   | Nestory45         | Nesta Jackson      | NIT/BIT/2023/2228       |
| 3   | augustino-massawe | Augustino Massawe  | NIT/BIT/2022/1773       |
| 4   | osmark764-2342    | Martin Shelukindo  | NIT/BIT/2023/2342       |
| 5   | salmakagogo       | Salma Kagogo       | NIT/BIT/2023/2058       |
| 6   | Shubi09           | Peter Shubi        | NIT/BIT/2022/1897       |
| 7   | MKIZA2003         | Samson Nilibe      | NIT/BIT/2023/2371       |
| 8   | Martha09-lee      | Martha Masinda     | NIT/BIT/2023/2190       |
| 9   | lulukway3-svg     | Lulu Kway          | NIT/BIT/2023/2366       |
| 10  | Laizersekino      | Sekino Laizer      | NIT/BIT/2023/2279       |
| 11  | INNOVATOR90       | Mustafa Pingili    | NIT/BIT/2023/2040       |
| 12  | HidayaNuruHussein | Hidaya Hussein     | NIT/BIT/2023/2155       |
| 13  | harryhagai        | Hagai Ngobey       | NIT/BIT/2023/2185       |
| 14  | aminaiddy         | Amina Iddi         | NIT/BIT/2023/2043       |
| 15  | Dean-mongi        | Dean Mongi         | NIT/BIT/2023/2039       |
| 16  | Frencknyondo      | Frank Nyondo       | NIT/BIT/2023/2092       |
---

### Screenshots
<!-- Second row: 2 images -->
<p float="left">
  <img src="https://i.postimg.cc/PfSbBP17/1.jpg" width="30%" />
  <img src="https://i.postimg.cc/zf33HGyb/2.jpg" width="30%" />
  <img src="https://i.postimg.cc/05CxxqQ1/3.jpg" width="30%" />
</p>

<!-- First row: 3 images -->
<p float="left">
  <img src="https://i.postimg.cc/RVFrB6yQ/5.jpg" width="30%" />
  <img src="https://i.postimg.cc/CKDTQ3t6/4.jpg" width="30%" />
  <img src="https://i.postimg.cc/gkgb1q0y/7.png" width="30%" />
</p>

---
## Overview

This application allows users to create accounts, securely log in, and exchange messages with other users in real time. It is powered by Firebase services to provide fast and reliable message delivery, secure authentication, and seamless cloud-based data synchronization. 
By leveraging Firebase, the app ensures scalable performance, consistent real-time updates, and low-latency communication across multiple devices.

---

##  Features

### **User Authentication**

The application includes a secure authentication system powered by **Firebase Authentication**, allowing users to safely create accounts and log in using their email and password. Firebase handles password encryption, session management, and authentication validation, ensuring user data is protected and access is restricted only to authorized users.

Key capabilities include:

* Secure **sign-up** and **login** using Firebase Authentication
* **Email and password-based authentication** with Firebase-managed security
* Persistent login sessions, so users don’t need to sign in repeatedly

---

### **User Directory**

The app provides a real-time user directory that displays all registered users. This directory updates instantly whenever a new user registers or user information changes. It also supports presence tracking, allowing users to see who is currently active or offline.

Key capabilities include:

* View all registered users in real time
* Automatically updates when users join or leave
* Displays **online/offline presence**, improving communication and usability

---

### **One-to-One Real-Time Chat**

The core feature of the application is a private one-to-one chat system built using **Cloud Firestore**, enabling instant message delivery with real-time updates. Messages are stored securely in the cloud, and conversations remain accessible across devices.

Key capabilities include:

* Real-time messaging with instant synchronization
* Messages stored in Firestore for reliability and persistence
* Message timestamps to show when messages were sent
* Read status support (e.g., delivered/seen), improving chat transparency

---

### **Push Notifications**

To ensure users never miss important messages, the application integrates **Firebase Cloud Messaging (FCM)**. When a user receives a new message while offline or not actively using the app, a push notification is sent instantly to their device.

Key capabilities include:

* Real-time notifications for new incoming messages
* Works even when the app is in the background or closed
* Implemented using Firebase Cloud Messaging (FCM) for fast delivery and scalability

---

## Technologies Used

- **Flutter** – Cross-platform mobile app development
- **Firebase Authentication** – Secure user authentication
- **Cloud Firestore** – Real-time NoSQL database
- **Firebase Cloud Messaging (FCM)** – Push notification service

---


## Setup Instructions

Follow the steps below to set up and run the project locally on your machine.

---

### 1. **Clone the Repository**

First, clone the project from GitHub and navigate into the project directory:

```bash
git clone https://github.com/augustino-massawe/flutter-chating-app-using-firebase.git
cd flutter-chating-app-using-firebase
```

---

### 2. **Install Flutter Dependencies**

Run the command below to download and install all required packages listed in `pubspec.yaml`:

```bash
flutter pub get
```

---

### 3. **Set Up Firebase for the Project**

This project requires Firebase configuration to enable authentication, Firestore, and push notifications.

Steps:

* Go to the **Firebase Console**
* Create a new Firebase project (or use an existing one)
* Add an Android and/or iOS app to the Firebase project
* Download the Firebase configuration file:

  * Android: `google-services.json`
  * iOS: `GoogleService-Info.plist`

Place the files in the correct directories:

 **Android**

```
android/app/google-services.json
```

 **iOS**

```
ios/Runner/GoogleService-Info.plist
```

---

### 4. **Enable Firebase Services**

In the Firebase Console, enable the following services:

* **Firebase Authentication**

  * Enable **Email/Password** sign-in method

* **Cloud Firestore**

  * Create a Firestore database
  * Set Firestore rules (for development, you may use test mode)

* **Firebase Cloud Messaging (FCM)**

  * Enable push notifications
  * Configure notification permissions (especially for Android 13+ and iOS)

---

### 5. **Run the Application**

After setup is complete, run the app using:

```bash
flutter run
```

Make sure you have:

* A connected Android device, emulator, or iOS simulator
* Flutter properly installed and configured

---

### 6. **(Optional) Build the APK**

To generate a release APK for Android:

```bash
flutter build apk --release
```

---

