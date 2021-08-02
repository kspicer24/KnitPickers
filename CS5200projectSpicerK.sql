CREATE DATABASE  IF NOT EXISTS `projectdatabasespicerk` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `projectdatabasespicerk`;
-- MySQL dump 10.13  Distrib 8.0.21, for Win64 (x86_64)
--
-- Host: localhost    Database: projectdatabasespicerk
-- ------------------------------------------------------
-- Server version	8.0.21

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `comments_on`
--

DROP TABLE IF EXISTS `comments_on`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comments_on` (
  `username` varchar(22) NOT NULL,
  `pattern` int NOT NULL,
  `user_comment` varchar(280) NOT NULL,
  `comment_date` date DEFAULT NULL,
  PRIMARY KEY (`username`,`pattern`),
  KEY `pattern` (`pattern`),
  CONSTRAINT `comments_on_ibfk_1` FOREIGN KEY (`username`) REFERENCES `user_member` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `comments_on_ibfk_2` FOREIGN KEY (`pattern`) REFERENCES `pattern` (`patternID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comments_on`
--

LOCK TABLES `comments_on` WRITE;
/*!40000 ALTER TABLE `comments_on` DISABLE KEYS */;
INSERT INTO `comments_on` VALUES ('i<3yarn93',4,'so easy and quick! I love making these while watching tv','2020-12-07'),('i<3yarn93',10,'one of my favorite scarves :)','2020-12-07');
/*!40000 ALTER TABLE `comments_on` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pattern`
--

DROP TABLE IF EXISTS `pattern`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pattern` (
  `patternID` int NOT NULL AUTO_INCREMENT,
  `patternName` varchar(50) NOT NULL,
  `stitchType` enum('knit','crochet') DEFAULT NULL,
  `category` varchar(22) DEFAULT NULL,
  `poster` varchar(22) DEFAULT NULL,
  `patternFile` varchar(500) NOT NULL,
  `text_desc` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`patternID`),
  UNIQUE KEY `patternName` (`patternName`),
  KEY `poster` (`poster`),
  CONSTRAINT `pattern_ibfk_1` FOREIGN KEY (`poster`) REFERENCES `user_member` (`username`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pattern`
--

LOCK TABLES `pattern` WRITE;
/*!40000 ALTER TABLE `pattern` DISABLE KEYS */;
INSERT INTO `pattern` VALUES (4,'quick pot holders','crochet','pot holder','knitter22','https://www.poshpatternsblog.com/free-crochet-pattern-easy-pot-holders-or-hot-pads/','super quick and easy! never buy pot holders again!'),(7,'baby frog hat','crochet','hat','knitter22','https://www.poshpatternsblog.com/free-crochet-pattern-baby-frog-hat/','super cute frog hat'),(10,'seed stitch scarf','crochet','scarf','knitter22','https://www.poshpatternsblog.com/free-knitting-pattern-seed-stitch-scarf/','beautiful and professional looking scarf! makes an awesome gift'),(12,'vine lace scarf','knit','scarf','i<3yarn93','https://www.poshpatternsblog.com/free-knitting-pattern-vine-lace-scarf/','amazing and easy to make!'),(14,'slouchy beanie','crochet','hat','i<3yarn93','https://www.poshpatternsblog.com/free-puff-stitch-slouchy-hat-crochet-pattern/','super fashionable and easy to make'),(15,'pretty gloves','crochet','gloves','kspice124','https://www.poshpatternsblog.com/free-crochet-pattern-baby-frog-hat/','ddd');
/*!40000 ALTER TABLE `pattern` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `queues`
--

DROP TABLE IF EXISTS `queues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `queues` (
  `username` varchar(22) NOT NULL,
  `patternID` int NOT NULL,
  `position` int DEFAULT '0',
  PRIMARY KEY (`username`,`patternID`),
  KEY `patternID` (`patternID`),
  CONSTRAINT `queues_ibfk_1` FOREIGN KEY (`username`) REFERENCES `user_member` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `queues_ibfk_2` FOREIGN KEY (`patternID`) REFERENCES `pattern` (`patternID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `queues`
--

LOCK TABLES `queues` WRITE;
/*!40000 ALTER TABLE `queues` DISABLE KEYS */;
INSERT INTO `queues` VALUES ('i<3yarn93',10,1),('kspice124',10,1);
/*!40000 ALTER TABLE `queues` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stash`
--

DROP TABLE IF EXISTS `stash`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stash` (
  `username` varchar(22) NOT NULL,
  `yarn` int NOT NULL,
  `color` varchar(22) NOT NULL,
  PRIMARY KEY (`username`,`yarn`,`color`),
  KEY `yarn` (`yarn`),
  CONSTRAINT `stash_ibfk_1` FOREIGN KEY (`username`) REFERENCES `user_member` (`username`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `stash_ibfk_2` FOREIGN KEY (`yarn`) REFERENCES `yarn` (`yarnID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stash`
--

LOCK TABLES `stash` WRITE;
/*!40000 ALTER TABLE `stash` DISABLE KEYS */;
INSERT INTO `stash` VALUES ('i<3yarn93',6,'grey');
/*!40000 ALTER TABLE `stash` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_member`
--

DROP TABLE IF EXISTS `user_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_member` (
  `username` varchar(22) NOT NULL,
  `pword` varchar(22) NOT NULL,
  `fName` varchar(22) DEFAULT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_member`
--

LOCK TABLES `user_member` WRITE;
/*!40000 ALTER TABLE `user_member` DISABLE KEYS */;
INSERT INTO `user_member` VALUES ('i<3yarn93','yarniscool','Allie'),('knitter22','knitter22','Candice'),('kspice124','kristi','Kristi');
/*!40000 ALTER TABLE `user_member` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `uses`
--

DROP TABLE IF EXISTS `uses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `uses` (
  `pattern` int NOT NULL,
  `yarn` int NOT NULL,
  PRIMARY KEY (`pattern`,`yarn`),
  KEY `yarn` (`yarn`),
  CONSTRAINT `uses_ibfk_1` FOREIGN KEY (`pattern`) REFERENCES `pattern` (`patternID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `uses_ibfk_2` FOREIGN KEY (`yarn`) REFERENCES `yarn` (`yarnID`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `uses`
--

LOCK TABLES `uses` WRITE;
/*!40000 ALTER TABLE `uses` DISABLE KEYS */;
INSERT INTO `uses` VALUES (7,3),(10,4),(12,5),(14,6);
/*!40000 ALTER TABLE `uses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `yarn`
--

DROP TABLE IF EXISTS `yarn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `yarn` (
  `yarnID` int NOT NULL AUTO_INCREMENT,
  `brand` varchar(22) DEFAULT NULL,
  `style` varchar(55) DEFAULT NULL,
  PRIMARY KEY (`yarnID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `yarn`
--

LOCK TABLES `yarn` WRITE;
/*!40000 ALTER TABLE `yarn` DISABLE KEYS */;
INSERT INTO `yarn` VALUES (1,'red heart','botique treasure'),(2,'lily','sugar n cream'),(3,'red heart','super saver'),(4,'loops and threads','charisma'),(5,'bernat','softee chunky'),(6,'bernat','softee baby');
/*!40000 ALTER TABLE `yarn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'projectdatabasespicerk'
--
/*!50003 DROP FUNCTION IF EXISTS `checkLogin` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `checkLogin`(uname VARCHAR(22), psword VARCHAR(22)) RETURNS int
    DETERMINISTIC
BEGIN
	IF uname NOT IN (SELECT username FROM user_member)
		THEN return -1;
	ELSEIF psword NOT IN (SELECT pword FROM user_member WHERE user_member.username = uname)
		THEN return 0;
	ELSE 
		return 1;
    END IF;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `checkQueue` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `checkQueue`(pid int, uname VARCHAR(22)) RETURNS int
    DETERMINISTIC
BEGIN
    DECLARE tempPos int;
    DECLARE maxPos int DEFAULT 0;
    DECLARE tempid int;
    DECLARE records TINYINT DEFAULT TRUE;
    DECLARE myCursor CURSOR FOR SELECT patternID, position FROM queues WHERE username = uname;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET records=false;
    
    OPEN myCursor;
    WHILE records DO
		FETCH myCursor INTO tempid, tempPos;
		-- check if item in queue
			IF tempID = pid THEN RETURN -1;
		-- if not, return the next position
			END IF;
			IF tempPos > maxPos THEN SET maxPos = tempPos;
            END IF;
	END WHILE;
    CLOSE myCursor;
    RETURN maxPos + 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `checkUniqueUsername` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `checkUniqueUsername`(uname VARCHAR(22)) RETURNS int
    DETERMINISTIC
BEGIN
	IF uname NOT IN (SELECT username FROM user_member) THEN RETURN 1; -- uniqe username]
    ELSE RETURN -1; -- not valid
    END IF;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `checkYarnExists` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `checkYarnExists`(b VARCHAR(22), s VARCHAR(22)) RETURNS int
    DETERMINISTIC
BEGIN
	DECLARE records TINYINT DEFAULT TRUE;
    DECLARE tempID int DEFAULT -1;
    DECLARE myCursor CURSOR FOR (SELECT yarnID FROM yarn WHERE yarn.brand = b AND yarn.style = s);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET records = false;
    
    OPEN myCursor;
    WHILE records = TRUE 
		DO
        FETCH myCursor INTO tempID;
	END WHILE;
    
    RETURN tempID;
    

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `deletePattern` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `deletePattern`(pid int) RETURNS int
    DETERMINISTIC
BEGIN
	DELETE FROM pattern WHERE patternID = pid;
    return 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `getPatternID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `getPatternID`(pName VARCHAR(22)) RETURNS int
    DETERMINISTIC
BEGIN
	DECLARE records TINYINT DEFAULT TRUE;
    DECLARE tempID int DEFAULT -1;
    DECLARE myCursor CURSOR FOR (SELECT patternID FROM pattern WHERE patternName = pName);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET records = false;
    
    OPEN myCursor;
    WHILE records = TRUE 
		DO
        FETCH myCursor INTO tempID;
	END WHILE;
    
    RETURN tempID;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `getYarnID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `getYarnID`(brand VARCHAR(22), style VARCHAR(22)) RETURNS int
    DETERMINISTIC
BEGIN
	
    IF brand IN (SELECT brand FROM yarn)
		THEN 
        IF style IN (SELECT style FROM yarn WHERE yarn.brand = brand)
			THEN
            return (SELECT yarnID FROM yarn WHERE yarn.brand = brand AND yarn.style = style LIMIT 1);
		END IF;
	END IF;
    
    return -1;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `getYarnWeight` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `getYarnWeight`(yarnID int) RETURNS int
    DETERMINISTIC
BEGIN
	IF yarnID IN (SELECT yarnID FROM yarn)
		THEN
        return (SELECT weight FROM yarn WHERE yarn.yarnID = yarnID);
	END IF;
    
    return -1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getComments` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getComments`(pid int)
BEGIN
	SELECT username, user_comment, comment_date FROM comments_on WHERE pattern = pid ORDER BY comment_date DESC;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getQueue` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getQueue`(userID VARCHAR(22))
BEGIN

    SELECT pattern.patternID, patternName, stitchType, category, poster, patternFile, text_desc 
		FROM pattern JOIN (SELECT patternID, position FROM queues WHERE username = userID) as q
			ON pattern.patternID = q.patternID
		ORDER BY position;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getStash` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getStash`(userID VARCHAR(22))
BEGIN
    
    SELECT brand, style, color FROM (SELECT yarn, color FROM stash WHERE username = userID GROUP BY yarn)as s 
    JOIN yarn ON yarn.yarnID = s.yarn 
    ORDER BY brand, style;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getUsedYarn` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getUsedYarn`(pattID int)
BEGIN 
	SELECT brand, style
		FROM yarn JOIN (SELECT yarn FROM uses WHERE pattern = pattID) as u
        ON yarn.yarnID = u.yarn;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-12-09 14:53:07
