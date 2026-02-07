# Firebase Database Structure – Chat Application

This document defines the Firestore database schema for a real-time chat application, including collections, fields, relationships, indexes, and common queries.

---

## Collections Overview

- **Users** – User profile and presence information  
- **Chats** – Chat metadata (one-to-one and group chats)  
- **Messages** – Individual chat messages  
- **Notifications (Optional)** – In-app notification records  

---

## Users Collection

**Collection Name:** `users`  
**Document ID:** Firebase Authentication UID

| Field Name  | Type      | Required | Default | Description |
|------------|-----------|----------|---------|-------------|
| `id`        | string    | Yes      | —       | Unique user identifier (Firebase Auth UID) |
| `name`      | string    | Yes      | —       | Display name |
| `email`     | string    | Yes      | —       | User email address |
| `photoURL`  | string    | No       | `null`  | Profile picture URL |
| `lastSeen`  | timestamp | No       | `null`  | Last active timestamp |
| `isOnline`  | boolean   | Yes      | `false` | Online status |
| `createdAt` | timestamp | Yes      | —       | Account creation time |
| `pushToken` | string    | No       | `null`  | FCM push notification token |

---

## Messages Collection

**Collection Name:** `messages`  
**Document ID:** Auto-generated or custom

| Field Name    | Type      | Required | Default | Description |
|--------------|-----------|----------|---------|-------------|
| `id`          | string    | Yes      | —       | Unique message ID |
| `senderId`    | string    | Yes      | —       | Sender user ID |
| `receiverId`  | string    | Yes      | —       | Receiver user ID |
| `content`     | string    | Yes      | —       | Message content |
| `timestamp`   | timestamp | Yes      | —       | Time message was sent |
| `isRead`      | boolean   | Yes      | `false` | Read status |
| `messageType` | string    | Yes      | `text`  | Message type (`text`, `image`, `video`, etc.) |
| `mediaUrl`    | string    | No       | `null`  | Media URL if applicable |

---

## Chats Collection

**Collection Name:** `chats`  
**Document ID:** `chatId`

| Field Name         | Type      | Required | Default | Description |
|-------------------|-----------|----------|---------|-------------|
| `chatId`           | string    | Yes      | —       | Unique chat identifier |
| `participants`     | array     | Yes      | —       | Array of participant user IDs |
| `lastMessage`      | string    | No       | `null`  | Last message preview |
| `lastMessageTime`  | timestamp | No       | `null`  | Timestamp of last message |
| `unreadCount`      | number    | Yes      | `0`     | Unread message count |
| `isGroupChat`      | boolean   | Yes      | `false` | Group chat indicator |

---

## Notifications Collection (Optional)

**Collection Name:** `notifications`  
**Document ID:** Auto-generated

| Field Name  | Type      | Required | Default | Description |
|------------|-----------|----------|---------|-------------|
| `id`        | string    | Yes      | —       | Notification ID |
| `userId`    | string    | Yes      | —       | Target user ID |
| `title`     | string    | Yes      | —       | Notification title |
| `body`      | string    | Yes      | —       | Notification message |
| `data`      | map       | No       | `null`  | Extra metadata |
| `timestamp` | timestamp | Yes      | —       | Creation time |
| `isRead`    | boolean   | Yes      | `false` | Read status |

---

## Database Relationships

- **Users ↔ Messages**: Users send and receive messages  
- **Users ↔ Chats**: Users participate in chats  
- **Chats ↔ Messages**: Chats contain messages  
- **Users ↔ Notifications**: Users receive notifications  

---

## Required Indexes

### Firestore Index Configuration

- **Users**
  - Index on `isOnline`

- **Messages**
  - Composite index on:
    - `senderId`
    - `receiverId`
    - `timestamp`

- **Chats**
  - Index on `participants` (array-contains)

---

## Common Queries

- Retrieve all users except the current user
- Retrieve messages between two users ordered by timestamp
- Retrieve all chats for a specific user
- Retrieve unread message count for a user

---
