CREATE DATABASE SocialDB;
USE SocialDB;

CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    bio TEXT,
    profile_pic VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Followers (
    follower_id INT,
    following_id INT,
    PRIMARY KEY (follower_id, following_id),
    CHECK (follower_id <> following_id),
    FOREIGN KEY (follower_id) REFERENCES Users(user_id),
    FOREIGN KEY (following_id) REFERENCES Users(user_id)
);

CREATE TABLE Likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    post_id INT,
    UNIQUE(user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (post_id) REFERENCES Posts(post_id)
);

CREATE TABLE Comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT,
    user_id INT,
    comment_text TEXT,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Messages (
    message_id INT PRIMARY KEY AUTO_INCREMENT,
    sender_id INT,
    receiver_id INT,
    message_text TEXT,
    FOREIGN KEY (sender_id) REFERENCES Users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES Users(user_id)
);

CREATE TABLE Notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE
);

CREATE TABLE Tags (
    tag_id INT PRIMARY KEY AUTO_INCREMENT,
    tag_name VARCHAR(50) UNIQUE
);

CREATE TABLE PostTags (
    post_id INT,
    tag_id INT,
    PRIMARY KEY(post_id, tag_id)
);

-- USERS DATA
INSERT INTO Users(username,email,password,full_name,bio)
VALUES
('john','john@mail.com','123','John Doe','Software Developer'),
('alice','alice@mail.com','123','Alice Smith','Data Analyst'),
('bob','bob@mail.com','123','Bob Brown','UI Designer'),
('mary','mary@mail.com','123','Mary Johnson','HR Manager'),
('alex','alex@mail.com','123','Alex White','Backend Developer');

-- POSTS DATA
INSERT INTO Posts(user_id,content)
VALUES
(1,'Hello world from John'),
(2,'Data Science is amazing'),
(3,'UI Design trends 2026'),
(4,'Hiring updates in tech industry'),
(5,'Node.js backend tips');

-- LIKES DATA
INSERT INTO Likes(user_id,post_id)
VALUES
(2,1),(3,1),(4,2),(5,2),(1,3);

-- COMMENTS DATA
INSERT INTO Comments(post_id,user_id,comment_text)
VALUES
(1,2,'Nice post!'),
(1,3,'Great work!'),
(2,1,'Very informative'),
(3,4,'Good design insights');

-- FOLLOWERS DATA
INSERT INTO Followers(follower_id,following_id)
VALUES
(1,2),(1,3),(2,3),(3,4),(4,5);

-- MESSAGES DATA
INSERT INTO Messages(sender_id,receiver_id,message_text)
VALUES
(1,2,'Hi Alice!'),
(2,1,'Hello John!'),
(3,4,'Hey Mary'),
(4,5,'Welcome Alex');

-- TAGS DATA
INSERT INTO Tags(tag_name)
VALUES
('Tech'),('AI'),('Design'),('HR'),('Programming');

-- POST TAGS
INSERT INTO PostTags(post_id,tag_id)
VALUES
(1,5),(2,2),(3,3),(4,4),(5,5);

-- NOTIFICATIONS
INSERT INTO Notifications(user_id,message)
VALUES
(1,'Welcome John'),
(2,'New follower'),
(3,'Post liked'),
(4,'New comment'),
(5,'Message received');

UPDATE Users
SET bio='Senior Software Engineer'
WHERE user_id=1;

-- Update post content
UPDATE Posts
SET content='Updated: Node.js backend advanced tips'
WHERE post_id=5;

-- Mark notification as read
UPDATE Notifications
SET is_read=TRUE
WHERE user_id=1;

-- Delete a comment
DELETE FROM Comments
WHERE comment_id=3;

-- Remove a like
DELETE FROM Likes
WHERE user_id=5 AND post_id=2;

-- Delete a message
DELETE FROM Messages
WHERE message_id=2;

-- All users
SELECT * FROM Users;

-- User posts
SELECT u.username, p.content
FROM Users u
JOIN Posts p ON u.user_id=p.user_id;

-- Likes per post
SELECT post_id, COUNT(*) AS total_likes
FROM Likes
GROUP BY post_id;

INSERT INTO Users(username,email,password,full_name)
VALUES('alex','alex@mail.com','123','Alex John');

UPDATE Users SET bio='Developer' WHERE user_id=1;

DELETE FROM Posts WHERE post_id=2;
-- joins
SELECT u.username, p.content
FROM Users u
INNER JOIN Posts p ON u.user_id=p.user_id;
-- groupby
SELECT user_id, COUNT(*)
FROM Posts
GROUP BY user_id
HAVING COUNT(*)>2;
-- subquery
SELECT username FROM Users
WHERE user_id IN (SELECT user_id FROM Posts);
-- view
CREATE VIEW Feed AS
SELECT u.username,p.content
FROM Users u JOIN Posts p ON u.user_id=p.user_id;
-- looping
DELIMITER $$

CREATE PROCEDURE while_loop_demo()
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= 10 DO
        INSERT INTO notifications(user_id, message)
        VALUES (1, CONCAT('Loop iteration number: ', i));

        SET i = i + 1;
    END WHILE;

END $$

DELIMITER ;
CALL while_loop_demo();

-- procedure
CREATE PROCEDURE AddPost(IN uid INT, IN msg TEXT)
BEGIN
INSERT INTO Posts(user_id,content) VALUES(uid,msg);
END;

-- functions
CREATE FUNCTION TotalPosts(uid INT)
RETURNS INT
BEGIN
DECLARE total INT;
SELECT COUNT(*) INTO total FROM Posts WHERE user_id=uid;
RETURN total;
END;

-- trigger
CREATE TRIGGER after_insert_post
AFTER INSERT ON Posts
FOR EACH ROW
INSERT INTO Notifications(user_id,message)
VALUES(NEW.user_id,'New Post Created');

-- transactions
START TRANSACTION;
UPDATE Users SET bio='Updated';
SAVEPOINT sp1;
ROLLBACK TO sp1;
COMMIT;

WITH PostCount AS (
SELECT user_id, COUNT(*) cnt FROM Posts GROUP BY user_id
)
SELECT * FROM PostCount;

CREATE USER 'admin'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON socialdb.* TO 'admin'@'localhost';
REVOKE INSERT ON socialdb.* FROM 'admin'@'localhost';
