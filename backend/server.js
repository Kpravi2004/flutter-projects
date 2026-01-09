// ================= IMPORTS =================
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const db = require("./db");

const app = express();

app.use(cors());
app.use(bodyParser.json());

app.get("/", (req, res) => {
  res.send("✅ Server is running");
});

app.post("/signup", (req, res) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({
      success: false,
      message: "All fields are required",
    });
  }

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

const PORT = 3000;

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});

app.post("/login", (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({
      success: false,
      message: "Email and password are required",
    });
  }

  const loginSql = "SELECT * FROM users WHERE email = ?";
  db.query(loginSql, [email], (err, result) => {
    if (err) {
      console.error("Login error:", err);
      return res.status(500).json({
        success: false,
        message: "Database error",
      });
    }


    if (result.length === 0) {
      return res.json({
        success: false,
        message: "Invalid email or password",
      });
    }

    const user = result[0];

    if (user.password !== password) {
      return res.json({
        success: false,
        message: "Invalid email or password",
      });
    }

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
