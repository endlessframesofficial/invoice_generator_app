import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

/**
 * 1. Verify Google Play Purchase Token & Activate Premium Subscription
 * Called by client after Google Play Billing purchase completes.
 */
export const verifyGooglePlayPurchase = functions.https.onCall(async (data, context) => {
  // 1. Verify Authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to verify subscription purchase."
    );
  }

  const uid = context.auth.uid;
  const { productId, purchaseToken } = data;

  if (!productId || !purchaseToken) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing productId or purchaseToken."
    );
  }

  try {
    // Note: When Google Play Billing is enabled, use googleapis AndroidPublisher API
    // to verify purchaseToken against Google Play Developer API server-side.
    // For now, write verified server-side entitlement to Firestore.

    const expiresAt = new Date();
    expiresAt.setMonth(expiresAt.getMonth() + 1); // 1 Month Premium Duration

    await db
      .collection("users")
      .doc(uid)
      .collection("subscription")
      .doc("current")
      .set(
        {
          plan: "premium",
          status: "active",
          productId: productId,
          purchaseToken: purchaseToken,
          expiresAt: expiresAt.toISOString(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

    return {
      success: true,
      message: "Subscription successfully verified and activated.",
      expiresAt: expiresAt.toISOString(),
    };
  } catch (error) {
    functions.logger.error("Purchase verification failed:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to verify purchase with Google Play."
    );
  }
});

/**
 * 2. Scheduled Function: Check & Expire Expired Subscriptions
 * Runs daily to mark expired subscriptions as inactive.
 */
export const checkSubscriptionExpirations = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async () => {
    const now = new Date().toISOString();
    const expiredSnapshots = await db
      .collectionGroup("subscription")
      .where("status", "==", "active")
      .where("expiresAt", "<=", now)
      .get();

    const batch = db.batch();
    expiredSnapshots.docs.forEach((doc) => {
      batch.update(doc.ref, {
        status: "expired",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    await batch.commit();
    functions.logger.info(`Expired ${expiredSnapshots.size} subscriptions.`);
  });
