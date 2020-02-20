import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

const fcm = admin.messaging();
const db = admin.firestore();

export const sendToChat = functions.firestore
  .document('chats/{roomID}/messages/{messageID}')
  .onCreate(async (snapshot, context) => {
    console.log('----------- START ----------');
    console.log('Chat roomID: ' + context.params.roomID);
    console.log('messageID: ' + context.params.messageID);
    
    console.log('snapshot.data(): ' + JSON.stringify(snapshot.data()));
    const message = snapshot.data();

    const notificationData = {
      title: 'You have a new message!', // Fail-safe default data.
      body: 'Check it out!', // Fail-safe default data.
      click_action: 'FLUTTER_NOTIFICATION_CLICK', // required only for onResume or onLaunch callbacks
    };

    const customData = {
      'routeName': '/home/chats',
      'tab': 'Private', // Defaults to 'private'
      'senderID': '',
    }

    if(message) {

      await db.collection('users').doc(message.senderID).get().then((snapshot) => {
        const userData = snapshot.data();
        console.log('userData: ' + JSON.stringify(userData));

        if(userData) {
          notificationData.title = userData.name;
        }
      });

      notificationData.body = `${message.message}`;
      customData.tab = message.members ? 'Private' : 'Tribes';
      customData.senderID = `${message.senderID}`;
    }

    const payload: admin.messaging.MessagingPayload = {
      notification: notificationData,
      data: customData,
    };

    console.log('payload: ' + JSON.stringify(payload));
    console.log('----------- END ----------');

    return fcm.sendToTopic(context.params.roomID, payload);
  });
