import * as QRCode from "qrcode";

const dummy_data = [{ product_id: 1 }];

// Function to generate QR code
async function generateQRCode(
  url: string,
  ipfsHash: string,
  productId: string
) {
  const qrData = `${url}/scan/${ipfsHash}-${productId}`;

  try {
    // Generate QR code and save as png
    await QRCode.toFile("qrcode.png", qrData, {
      errorCorrectionLevel: "H",
      type: "png",
      scale: 4
    });

    console.log("QR code has been saved as qrcode.png");
  } catch (err) {
    console.error("Failed to generate QR code: ", err);
  }
}

// Use the function
generateQRCode(
  "https://scan-guard.vercel.app",
  "QmT6yyoLvSJFw6bMV7cVEHNbn7F8vnaD4pGcvCRTBTSoP3",
  "cZoMp0aLc2"
);
