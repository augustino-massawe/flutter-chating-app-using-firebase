# Firebase Database Structure for Chat Application

## Collections and Fields

### 1. Users Collection
**Document ID**: Firebase Auth UID

```
+------------+-----------+------+-----+---------+-------+
| Field Name | Data Type | Null | Key | Default | Extra |
+------------+-----------+------+-----+---------+-------+
| id         | string    | NO   | PRI | NULL    |       |
| name       | string    | NO   |     | NULL    |       |
| email      | string    | NO   |     | NULL    |       |
| photoURL   | string    | YES  |     | NULL    |       |
| lastSeen   | timestamp | YES  |     | NULL    |       |
| isOnline   | boolean   | NO   |     | false   |       |
| createdAt  | timestamp | NO   |     | NULL    |       |
| pushToken  | string    | YES  |     | NULL    |       |
+------------+-----------+------+-----+---------+-------+
```

**Field Descriptions:**
- `id`: User's unique identifier (same as Firebase Auth UID), serves as primary key
- `name`: User's display name shown in the app interface
- `email`: User's email address used for authentication and identification
- `photoURL`: URL to user's profile picture, optional field for user avatars
- `lastSeen`: Timestamp of when user was last online, used for presence detection
- `isOnline`: Boolean flag indicating current online status, defaults to false
- `createdAt`: Timestamp when user account was created, used for account management
- `pushToken`: FCM token for push notifications, optional field for messaging

### 2. Messages Collection
**Document ID**: Auto-generated or custom message ID

```
+------------+-----------+------+-----+---------+-------+
| Field Name | Data Type | Null | Key | Default | Extra |
+------------+-----------+------+-----+---------+-------+
| id         | string    | NO   | PRI | NULL    |       |
| senderId   | string    | NO   | MUL | NULL    |       |
| receiverId | string    | NO   | MUL | NULL    |       |
| content    | string    | NO   |     | NULL    |       |
| timestamp  | timestamp | NO   |     | NULL    |       |
| isRead     | boolean   | NO   |     | false   |       |
| messageType| string    | NO   |     | 'text'  |       |
| mediaUrl   | string    | YES  |     | NULL    |       |
+------------+-----------+------+-----+---------+-------+
```

**Field Descriptions:**
- `id`: Message unique identifier, serves as primary key for message lookup
- `senderId`: ID of the user who sent the message, foreign key to Users collection
- `receiverId`: ID of the user who received the message, foreign key to Users collection
- `content`: Message content/text, stores the actual message content
- `timestamp`: When the message was sent, used for message ordering and history
- `isRead`: Boolean flag indicating whether the message has been read, defaults to false
- `messageType`: Type of message (text, image, video, etc.), defaults to 'text'
- `mediaUrl`: URL for media files when messageType is not text, optional field

### 3. Chats Collection
**Document ID**: Chat ID (combination of user IDs)

```
+-----------------+-----------+------+-----+---------+-------+
| Field Name      | Data Type | Null | Key | Default | Extra |
+-----------------+-----------+------+-----+---------+-------+
| chatId          | string    | NO   | PRI | NULL    |       |
| participants    | array     | NO   | MUL | NULL    |       |
| lastMessage     | string    | YES  |     | NULL    |       |
| lastMessageTime | timestamp | YES  |     | NULL    |       |
| unreadCount     | number    | NO   |     | 0       |       |
| isGroupChat     | boolean   | NO   |     | false   |       |
+-----------------+-----------+------+-----+---------+-------+
```

**Field Descriptions:**
- `chatId`: Unique chat identifier, serves as primary key for chat lookup
- `participants`: Array of user IDs in the chat, foreign keys to Users collection
- `lastMessage`: Content of the last message, used for chat preview in chat list
- `lastMessageTime`: Time of the last message, used for chat ordering in chat list
- `unreadCount`: Number of unread messages, used for notification badges
- `isGroupChat`: Boolean flag indicating whether it's a group chat or one-on-one

### 4. Notifications Collection (Optional)
**Document ID**: Auto-generated notification ID

```
+------------+-----------+------+-----+---------+-------+
| Field Name | Data Type | Null | Key | Default | Extra |
+------------+-----------+------+-----+---------+-------+
| id         | string    | NO   | PRI | NULL    |       |
| userId     | string    | NO   | MUL | NULL    |       |
| title      | string    | NO   |     | NULL    |       |
| body       | string    | NO   |     | NULL    |       |
| data       | map       | YES  |     | NULL    |       |
| timestamp  | timestamp | NO   |     | NULL    |       |
| isRead     | boolean   | NO   |     | false   |       |
+------------+-----------+------+-----+---------+-------+
```

**Field Descriptions:**
- `id`: Notification ID, serves as primary key for notification lookup
- `userId`: User who should receive the notification, foreign key to Users collection
- `title`: Notification title, displayed in notification header
- `body`: Notification message, displayed in notification content
- `data`: Additional data for the notification, used for deep linking and extra context
- `timestamp`: When notification was created, used for notification ordering
- `isRead`: Boolean flag indicating whether notification has been read, defaults to false

## Database Relationships

1. **Users ↔ Messages**: Users send and receive messages
2. **Users ↔ Chats**: Users participate in chats
3. **Chats ↔ Messages**: Chats contain multiple messages
4. **Users ↔ Notifications**: Users receive notifications

## Required Indexes

- Users collection: Index on `isOnline` for online status queries
- Messages collection: Composite index on `senderId` + `receiverId` + `timestamp`
- Chats collection: Index on `participants` array for chat lookup

## Common Queries

- Get all users except current user
- Get messages between two users ordered by timestamp
- Get all chats for a specific user
- Get unread message count for a user