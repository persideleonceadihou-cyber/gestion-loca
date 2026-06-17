
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const PDFDocument = require("pdfkit");
const nodemailer = require("nodemailer");
const crypto = require("crypto");

admin.initializeApp();

// ─── Config email ─────────────────────────────────────────────────────────────
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: functions.config().email.user,
    pass: functions.config().email.pass,
  },
});

// ─── Webhook FedaPay ──────────────────────────────────────────────────────────
exports.fedapayWebhook = functions.https.onRequest(async (req, res) => {
  try {

    // ✅ 1. Vérification signature HMAC
    const sig = req.headers["x-fedapay-signature"];
    const expected = crypto
      .createHmac("sha256", functions.config().fedapay.webhook_secret)
      .update(JSON.stringify(req.body))
      .digest("hex");
    if (sig !== expected) {
      console.warn("⚠️ Signature invalide");
      return res.status(401).send("Unauthorized");
    }

    // ✅ 2. Ignorer les transactions non approuvées
    const { transaction } = req.body;
    if (!transaction || transaction.status !== "approved") {
      return res.status(200).send("ignored");
    }

    const txId        = transaction.id.toString();
    const meta        = transaction.custom_metadata || {};
    const locataireId = meta.locataire_id;

    // ✅ 3. Numéro de reçu généré une seule fois
    const numeroRecu = `REC-${Date.now()}`;

    // ✅ 4. Chercher le paiement dans Firestore
    const snapshot = await admin.firestore()
      .collection("paiements")
      .where("fedapay_tx_id", "==", txId)
      .limit(1)
      .get();

    if (snapshot.empty) return res.status(200).send("not found");

    const docRef  = snapshot.docs[0].ref;
    const paiData = snapshot.docs[0].data();

    // ✅ 5. Idempotence — évite le double traitement
    if (paiData.statut === "payé") {
      console.log(`ℹ️ Transaction ${txId} déjà traitée`);
      return res.status(200).send("already processed");
    }

    // ✅ 6. Récupérer les infos locataire
    const locDoc = await admin.firestore()
      .collection("locataires")
      .doc(locataireId)
      .get();

    if (!locDoc.exists) {
      console.error(`❌ Locataire introuvable : ${locataireId}`);
      return res.status(200).send("locataire not found");
    }
    const locataire = locDoc.data();

    // ✅ 7. Générer le PDF reçu
    const pdfBuffer = await genererRecuPDF({
      numeroRecu,
      nomLocataire: locataire.nom,
      email:        locataire.email,
      telephone:    locataire.telephone,
      bienNom:      paiData.description,
      montant:      paiData.montant,
      datePaiement: new Date(),
      txId,
      periode:      paiData.periode || "N/A",
    });

    // ✅ 8. Uploader le PDF dans Firebase Storage
    const bucket   = admin.storage().bucket();
    const fileName = `recus/${locataireId}/${txId}.pdf`;
    const fileRef  = bucket.file(fileName);

    await fileRef.save(pdfBuffer, { contentType: "application/pdf" });
    const [pdfUrl] = await fileRef.getSignedUrl({
      action:  "read",
      expires: "03-01-2030",
    });

    // ✅ 9. Envoyer l'email — même numeroRecu que le PDF
    await envoyerEmailRecu({
      email:        locataire.email,
      nomLocataire: locataire.nom,
      montant:      paiData.montant,
      bienNom:      paiData.description,
      periode:      paiData.periode || "",
      pdfBuffer,
      numeroRecu,
    });

    // ✅ 10. Mettre à jour Firestore
    await docRef.update({
      statut:        "payé",
      date_paiement: admin.firestore.FieldValue.serverTimestamp(),
      recu_url:      pdfUrl,
      recu_envoye:   true,
    });

    console.log(`✅ Reçu ${numeroRecu} envoyé à ${locataire.email}`);
    res.status(200).send("OK");

  } catch (err) {
    console.error("❌ Webhook error:", err);
    res.status(500).send("Error");
  }
});

// ─── Génération du PDF avec PDFKit ───────────────────────────────────────────
function genererRecuPDF(data) {
  return new Promise((resolve, reject) => {
    const doc    = new PDFDocument({ size: "A4", margin: 50 });
    const chunks = [];

    doc.on("data",  chunk => chunks.push(chunk));
    doc.on("end",   ()    => resolve(Buffer.concat(chunks)));
    doc.on("error", reject);

    const rouge = "#D85A30";
    const gris  = "#888780";
    const noir  = "#2C2C2A";
    const vert  = "#1D9E75";

    // ── En-tête ──────────────────────────────────────────────────────────────
    doc.rect(0, 0, 595, 100).fill(rouge);
    doc.fillColor("white")
       .fontSize(24).font("Helvetica-Bold")
       .text("REÇU DE PAIEMENT", 50, 30);
    doc.fontSize(11).font("Helvetica")
       .text("Gestion Locative — ImmoApp", 50, 60)
       .text(`N° ${data.numeroRecu}`, 400, 45, { align: "right" });

    // ── Date ─────────────────────────────────────────────────────────────────
    doc.fillColor(gris).fontSize(10)
       .text(`Date : ${data.datePaiement.toLocaleDateString("fr-FR", {
         day: "2-digit", month: "long", year: "numeric",
       })}`, 50, 120);

    // ── Séparateur ───────────────────────────────────────────────────────────
    doc.moveTo(50, 145).lineTo(545, 145).strokeColor("#D3D1C7").stroke();

    // ── Infos locataire ──────────────────────────────────────────────────────
    doc.fillColor(noir).fontSize(12).font("Helvetica-Bold")
       .text("LOCATAIRE", 50, 165);
    doc.font("Helvetica").fontSize(11).fillColor(gris)
       .text(data.nomLocataire, 50, 183)
       .text(data.email,        50, 198)
       .text(data.telephone,    50, 213);

    // ── Infos bien ───────────────────────────────────────────────────────────
    doc.fillColor(noir).fontSize(12).font("Helvetica-Bold")
       .text("BIEN LOUÉ", 300, 165);
    doc.font("Helvetica").fontSize(11).fillColor(gris)
       .text(data.bienNom, 300, 183)
       .text(data.periode, 300, 198);

    // ── Séparateur ───────────────────────────────────────────────────────────
    doc.moveTo(50, 245).lineTo(545, 245).strokeColor("#D3D1C7").stroke();

    // ── Tableau montant ──────────────────────────────────────────────────────
    doc.fillColor(noir).fontSize(12).font("Helvetica-Bold")
       .text("DÉTAIL DU PAIEMENT", 50, 265);

    doc.rect(50, 290, 495, 30).fill("#F1EFE8");
    doc.fillColor(gris).fontSize(10).font("Helvetica-Bold")
       .text("Description", 60,  300)
       .text("Montant",     470, 300, { align: "right", width: 65 });

    doc.rect(50, 320, 495, 36).fill("white").stroke();
    doc.fillColor(noir).font("Helvetica").fontSize(11)
       .text(data.bienNom, 60, 333)
       .text(`${data.montant.toLocaleString("fr-FR")} XOF`, 470, 333, {
         align: "right", width: 65,
       });

    doc.rect(50, 356, 495, 40).fill(rouge);
    doc.fillColor("white").font("Helvetica-Bold").fontSize(13)
       .text("TOTAL PAYÉ", 60, 370)
       .text(`${data.montant.toLocaleString("fr-FR")} XOF`, 470, 370, {
         align: "right", width: 65,
       });

    // ── Statut ───────────────────────────────────────────────────────────────
    doc.roundedRect(50, 415, 495, 45, 8).fill("#EAF3DE");
    doc.fillColor(vert).font("Helvetica-Bold").fontSize(14)
       .text("✓  PAIEMENT CONFIRMÉ", 130, 432);

    // ── Référence transaction ────────────────────────────────────────────────
    doc.fillColor(gris).font("Helvetica").fontSize(9)
       .text(`Référence FedaPay : ${data.txId}`, 50, 475, {
         align: "center", width: 495,
       });

    // ── Pied de page ─────────────────────────────────────────────────────────
    doc.moveTo(50, 760).lineTo(545, 760).strokeColor("#D3D1C7").stroke();
    doc.fillColor(gris).fontSize(9)
       .text(
         "Ce reçu est généré automatiquement et fait foi de votre paiement.",
         50, 772, { align: "center", width: 495 }
       );

    doc.end();
  });
}

// ─── Envoi email avec nodemailer ─────────────────────────────────────────────
async function envoyerEmailRecu({
  email, nomLocataire, montant, bienNom, periode, pdfBuffer, numeroRecu,
}) {
  const html = `
    <div style="font-family:sans-serif;max-width:560px;margin:0 auto">
      <div style="background:#D85A30;padding:24px 32px;border-radius:8px 8px 0 0">
        <h1 style="color:white;margin:0;font-size:22px">Reçu de paiement</h1>
        <p style="color:rgba(255,255,255,0.85);margin:4px 0 0">ImmoApp — Gestion Locative</p>
      </div>
      <div style="background:#fff;padding:32px;border:1px solid #eee;border-top:none;border-radius:0 0 8px 8px">
        <p style="color:#444">Bonjour <strong>${nomLocataire}</strong>,</p>
        <p style="color:#444">Votre paiement a bien été reçu et confirmé. Voici le récapitulatif :</p>
        <table style="width:100%;border-collapse:collapse;margin:20px 0">
          <tr style="background:#F1EFE8">
            <td style="padding:10px 14px;font-weight:bold;color:#5F5E5A">Bien</td>
            <td style="padding:10px 14px;color:#2C2C2A">${bienNom}</td>
          </tr>
          <tr>
            <td style="padding:10px 14px;font-weight:bold;color:#5F5E5A">Période</td>
            <td style="padding:10px 14px;color:#2C2C2A">${periode}</td>
          </tr>
          <tr style="background:#F1EFE8">
            <td style="padding:10px 14px;font-weight:bold;color:#5F5E5A">Montant</td>
            <td style="padding:10px 14px;color:#2C2C2A;font-weight:bold;font-size:16px">
              ${montant.toLocaleString("fr-FR")} XOF
            </td>
          </tr>
          <tr>
            <td style="padding:10px 14px;font-weight:bold;color:#5F5E5A">Statut</td>
            <td style="padding:10px 14px;color:#1D9E75;font-weight:bold">✓ Confirmé</td>
          </tr>
        </table>
        <p style="color:#888;font-size:13px">
          Le reçu officiel (PDF) est joint à cet email. Conservez-le pour vos archives.
        </p>
        <hr style="border:none;border-top:1px solid #eee;margin:24px 0">
        <p style="color:#aaa;font-size:12px;text-align:center">
          Cet email est envoyé automatiquement — merci de ne pas y répondre.
        </p>
      </div>
    </div>
  `;

  await transporter.sendMail({
    from:    `"ImmoApp" <${functions.config().email.user}>`,
    to:      email,
    subject: `✓ Reçu de paiement — ${bienNom} (${montant.toLocaleString("fr-FR")} XOF)`,
    html,
    attachments: [{
      filename:    `recu-${numeroRecu}.pdf`,
      content:     pdfBuffer,
      contentType: "application/pdf",
    }],
  });
}