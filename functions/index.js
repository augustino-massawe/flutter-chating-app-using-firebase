const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendChatNotification = functions.firestore
    .document("chatRooms/{chatRoomId}/messages/{messageId}")
    .onCreate(async (snapshot, context) => {
        try {
            const messageData = snapshot.data();
            const chatRoomId = context.params.chatRoomId;
            const senderUid = messageData.senderId;
            const messageText = messageData.text || "Attachment";

            if (!senderUid) {
                console.log("No senderId found — skipping");
                return null;
            }

            // Get sender name
            const senderDoc = await admin
                .firestore()
                .collection("users")
                .doc(senderUid)
                .get();

            const senderName = senderDoc.exists
                ? senderDoc.data().displayName
                || senderDoc.data().email
                || "Someone"
                : "Someone";

            // Get chat room participants
            const chatRoomDoc = await admin
                .firestore()
                .collection("chatRooms")
                .doc(chatRoomId)
                .get();

            if (!chatRoomDoc.exists) {
                console.log("Chat room not found — skipping");
                return null;
            }

            const participants = chatRoomDoc.data().participants || [];

            // Send to each recipient except sender
            const promises = participants
                .filter((uid) => uid !== senderUid)
                .map(async (recipientUid) => {
                    const recipientDoc = await admin
                        .firestore()
                        .collection("users")
                        .doc(recipientUid)
                        .get();

                    if (!recipientDoc.exists) return null;

                    const fcmToken = recipientDoc.data().fcmToken;
                    if (!fcmToken) {
                        console.log("No FCM token for " + recipientUid);
                        return null;
                    }

                    const bodyText = messageText.length > 100
                        ? messageText.substring(0, 100) + "..."
                        : messageText;

                    const msg = {
                        token: fcmToken,
                        notification: {
                            title: senderName,
                            body: bodyText,
                        },
                        data: {
                            chatRoomId: chatRoomId,
                            senderUid: senderUid,
                            senderName: senderName,
                            click_action: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        android: {
                            priority: "high",
                            notification: {
                                channelId: "chat_messages_channel",
                                priority: "high",
                                defaultSound: true,
                                defaultVibrateTimings: true,
                                clickAction: "FLUTTER_NOTIFICATION_CLICK",
                            },
                        },
                        apns: {
                            payload: {
                                aps: {
                                    alert: {
                                        title: senderName,
                                        body: bodyText,
                                    },
                                    badge: 1,
                                    sound: "default",
                                },
                            },
                        },
                        webpush: {
                            notification: {
                                title: senderName,
                                body: bodyText,
                                icon: "/icons/Icon-192.png",
                            },
                            fcmOptions: {
                                link: "/chat/" + chatRoomId,
                            },
                        },
                    };

                    try {
                        const res = await admin.messaging().send(msg);
                        console.log("Sent to " + recipientUid + ": " + res);
                        return res;
                    } catch (err) {
                        if (
                            err.code === "messaging/invalid-registration-token" ||
                            err.code === "messaging/registration-token-not-registered"
                        ) {
                            await admin
                                .firestore()
                                .collection("users")
                                .doc(recipientUid)
                                .update({
                                    fcmToken: admin.firestore.FieldValue.delete(),
                                });
                        }
                        console.error("Failed to send to " + recipientUid, err);
                        return null;
                    }
                });

            await Promise.all(promises);
            console.log("Done for chatRoom: " + chatRoomId);
            return null;
        } catch (error) {
            console.error("sendChatNotification error:", error);
            return null;
        }
    });