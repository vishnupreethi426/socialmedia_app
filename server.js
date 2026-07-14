const express = require("express");
const mysql = require("mysql");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

/* MYSQL CONNECTION */
const db = mysql.createConnection({
    host: "localhost",
    user: "root",
    password: "",
    database: "SocialDB"
});

db.connect(err => {
    if (err) console.log("DB Error:", err);
    else console.log("MySQL Connected");
});



/* ===================== USERS ===================== */

// GET USERS
app.get("/users", (req, res) => {
    db.query("SELECT * FROM Users", (err, result) => {
        if (err) throw err;
        res.json(result);
    });
});

// ADD USER
app.post("/users", (req, res) => {
    const { username, email, password, full_name } = req.body;

    db.query(
        "INSERT INTO Users(username,email,password,full_name) VALUES(?,?,?,?)",
        [username, email, password, full_name],
        (err) => {
            if (err) throw err;
            res.send("User Added");
        }
    );
});

// DELETE USER
app.delete("/users/:id", (req, res) => {
    db.query(
        "DELETE FROM Users WHERE user_id=?",
        [req.params.id],
        (err) => {
            if (err) throw err;
            res.send("User Deleted");
        }
    );
});

// UPDATE USER (IMPORTANT FOR UI)
app.put("/users/:id", (req, res) => {
    const { username, email } = req.body;

    db.query(
        "UPDATE Users SET username=?, email=? WHERE user_id=?",
        [username, email, req.params.id],
        (err) => {
            if (err) throw err;
            res.send("User Updated");
        }
    );
});



/* ===================== POSTS ===================== */

// GET POSTS (JOIN USERNAME - PROFESSIONAL)
app.get("/posts", (req, res) => {
    const sql = `
        SELECT Posts.post_id, Posts.content, Users.username
        FROM Posts
        JOIN Users ON Posts.user_id = Users.user_id
        ORDER BY Posts.post_id DESC
    `;

    db.query(sql, (err, result) => {
        if (err) throw err;
        res.json(result);
    });
});

// ADD POST
app.post("/posts", (req, res) => {
    const { user_id, content } = req.body;

    db.query(
        "INSERT INTO Posts(user_id,content) VALUES(?,?)",
        [user_id, content],
        (err) => {
            if (err) throw err;
            res.send("Post Added");
        }
    );
});

// DELETE POST
app.delete("/posts/:id", (req, res) => {
    db.query(
        "DELETE FROM Posts WHERE post_id=?",
        [req.params.id],
        (err) => {
            if (err) throw err;
            res.send("Post Deleted");
        }
    );
});

// UPDATE POST
app.put("/posts/:id", (req, res) => {
    const { content } = req.body;

    db.query(
        "UPDATE Posts SET content=? WHERE post_id=?",
        [content, req.params.id],
        (err) => {
            if (err) throw err;
            res.send("Post Updated");
        }
    );
});



/* ===================== START SERVER ===================== */

app.listen(3000, () => {
    console.log("Server running on port 3000");
});