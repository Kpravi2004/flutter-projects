const db = require("./db");

db.query("SELECT * FROM users", (err, result) => {
  if (err) {
    console.error("DB ERROR:", err);
  } else {
    console.log("DB SUCCESS:", result);
  }
});
