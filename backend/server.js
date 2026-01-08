// ================= IMPORTS =================
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const db = require("./db");

// ================= APP INIT =================
const app = express();

// ================= MIDDLEWARE =================
app.use(cors());
app.use(bodyParser.json());

// ================= TEST ROUTE =================
app.get("/", (req, res) => {
  res.send("✅ Server is running");
});

// ================= SIGNUP API =================
app.post("/signup", (req, res) => {
  const { name, email, password } = req.body;

  // 1️⃣ Backend validation
  if (!name || !email || !password) {
    return res.status(400).json({
      success: false,
      message: "All fields are required",
    });
  }

  // 2️⃣ Check duplicate email
  const checkEmailSql = "SELECT id FROM users WHERE email = ?";
  db.query(checkEmailSql, [email], (err, result) => {
    if (err) {
      console.error("Email check error:", err);
      return res.status(500).json({
        success: false,
        message: "Database error",
      });
    }

    if (result.length > 0) {
      return res.json({
        success: false,
        message: "Email already exists",
      });
    }

    // 3️⃣ Insert new user
    const insertSql =
      "INSERT INTO users (name, email, password) VALUES (?, ?, ?)";

    db.query(insertSql, [name, email, password], (err) => {
      if (err) {
        console.error("Insert error:", err);
        return res.status(500).json({
          success: false,
          message: "Signup failed",
        });
      }

      return res.json({
        success: true,
        message: "Signup successful",
      });
    });
  });
});

// ================= START SERVER =================
const PORT = 3000;

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
// ================= LOGIN API =================
app.post("/login", (req, res) => {
  const { email, password } = req.body;

  // 1️⃣ Validation
  if (!email || !password) {
    return res.status(400).json({
      success: false,
      message: "Email and password are required",
    });
  }

  // 2️⃣ Check email exists
  const loginSql = "SELECT * FROM users WHERE email = ?";
  db.query(loginSql, [email], (err, result) => {
    if (err) {
      console.error("Login error:", err);
      return res.status(500).json({
        success: false,
        message: "Database error",
      });
    }

    // Email not found
    if (result.length === 0) {
      return res.json({
        success: false,
        message: "Invalid email or password",
      });
    }

    const user = result[0];

    // 3️⃣ Check password (PLAIN TEXT for now)
    if (user.password !== password) {
      return res.json({
        success: false,
        message: "Invalid email or password",
      });
    }

    // 4️⃣ Success
    return res.json({
      success: true,
      message: "Login successful",
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
      },
    });
  });
});
