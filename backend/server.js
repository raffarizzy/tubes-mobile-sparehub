require("dotenv").config();
const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const { Xendit, Invoice } = require("xendit-node");

const app = express();
app.use(cors());
app.use(bodyParser.json());

const xendit = new Xendit({
  secretKey: process.env.XENDIT_SECRET_KEY,
});

const invoice = new Invoice({ secretKey: process.env.XENDIT_SECRET_KEY });

// ✅ Cek server hidup
app.get("/", (req, res) => {
  res.send("✅ Server Xendit aktif");
});

app.post("/create-invoice", async (req, res) => {
  const { amount, name, email } = req.body;

  if (!amount || !name || !email) {
    return res.status(400).json({ error: "Data tidak lengkap" });
  }

  try {
    console.log("📩 Request masuk:", { amount, name, email });

    const response = await invoice.createInvoice({
      data: {
        externalId: `inv-${Date.now()}`, // ✅ Wajib camelCase
        payerEmail: email,
        description: `Pembayaran dari ${name}`,
        amount: Number(amount),
        paymentMethods: ["QRIS"],

        successRedirectUrl: "http://localhost:3000/success",
        failureRedirectUrl: "http://localhost:3000/failed",
      },
    });

    console.log("✅ Invoice sukses:", response.invoiceUrl);

    res.json({
      invoice_url: response.invoiceUrl,
    });
  } catch (err) {
    console.error("❌ Xendit error:", err);
    res.status(500).json({ error: err.message });
  }
});

// ✅ WAJIB: listen ke 0.0.0.0
app.listen(3000, "0.0.0.0", () => {
  console.log("✅ Server berjalan di http://0.0.0.0:3000");
});
