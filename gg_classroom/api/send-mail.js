import nodemailer from "nodemailer";

export default async function handler(req, res) {
  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  const { email, name } = req.body;

  if (!email || !name) {
    res.status(400).json({ error: "Missing email or name" });
    return;
  }

  try {
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: process.env.GMAIL_USER, // Gmail để gửi
        pass: process.env.GMAIL_PASS  // App password 16 ký tự
      }
    });

    await transporter.sendMail({
      from: process.env.GMAIL_USER,
      to: email,
      subject: "Chúc mừng đăng ký thành công",
      text: `Chào ${name},\nCảm ơn bạn đã đăng ký!`
    });

    res.status(200).json({ message: "Email sent successfully!" });
  } catch (err) {
    console.error("Failed to send email:", err);
    res.status(500).json({ error: err.message });
  }
}
