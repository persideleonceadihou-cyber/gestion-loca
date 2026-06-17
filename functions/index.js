const {setGlobalOptions} = require("firebase-functions");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();
setGlobalOptions({ maxInstances: 10 });

// ─────────────────────────────────────────────
// Notification : Paiement reçu
// Se déclenche pour Cash, Manuel ET FedaPay (plus tard)
// ─────────────────────────────────────────────
exports.onPaymentCreated = onDocumentCreated(
  "users/{uid}/paiements/{paiementId}",
  async (event) => {
    const paiement = event.data.data();
    const { uid, paiementId } = event.params;

    logger.info(`Nouveau paiement pour ${uid}`, paiement);

    const userDoc = await admin.firestore().collection("users").doc(uid).get();
    const token = userDoc.data()?.fcmToken;

    if (!token) {
      logger.warn(`Aucun token FCM pour l'utilisateur ${uid}`);
      return;
    }

    const montant = (paiement.amount ?? 0).toLocaleString("fr-FR");

    await admin.messaging().send({
      token,
      notification: {
        title: "Paiement reçu ✅",
        body: `${paiement.tenantName} a payé ${montant} FCFA (${paiement.method}).`,
      },
      data: {
        type: "paiement_effectue",
        tenantId: paiement.tenantId ?? "",
        paiementId: paiementId,
      },
    });

    logger.info(`Notification envoyée à ${uid}`);
  }
);