-- MySQL dump 10.13  Distrib 5.7.16, for Linux (x86_64)
--
-- Host: localhost    Database: cardbot_db
-- ------------------------------------------------------
-- Server version	5.7.16-0ubuntu0.16.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `agents`
--

DROP TABLE IF EXISTS `agents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `aid` int(11) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agents`
--

LOCK TABLES `agents` WRITE;
/*!40000 ALTER TABLE `agents` DISABLE KEYS */;
INSERT INTO `agents` VALUES (1,46279756,NULL,NULL),(2,141945565,NULL,NULL),(3,156055289,NULL,NULL);
/*!40000 ALTER TABLE `agents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `card_products`
--

DROP TABLE IF EXISTS `card_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type_name` varchar(255) DEFAULT NULL,
  `store_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_card_products_on_store_id` (`store_id`),
  CONSTRAINT `fk_rails_e0da833334` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `card_products`
--

LOCK TABLES `card_products` WRITE;
/*!40000 ALTER TABLE `card_products` DISABLE KEYS */;
/*!40000 ALTER TABLE `card_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `card_transactions`
--

DROP TABLE IF EXISTS `card_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` varchar(255) DEFAULT NULL,
  `trans_type` varchar(255) DEFAULT NULL,
  `amount` float DEFAULT NULL,
  `store_id` int(11) DEFAULT NULL,
  `agent_id` int(11) DEFAULT NULL,
  `card_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_card_transactions_on_store_id` (`store_id`),
  KEY `index_card_transactions_on_agent_id` (`agent_id`),
  KEY `index_card_transactions_on_card_id` (`card_id`),
  CONSTRAINT `fk_rails_31c51d51a4` FOREIGN KEY (`card_id`) REFERENCES `cards` (`id`),
  CONSTRAINT `fk_rails_5ed15be412` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`),
  CONSTRAINT `fk_rails_7090c4df60` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `card_transactions`
--

LOCK TABLES `card_transactions` WRITE;
/*!40000 ALTER TABLE `card_transactions` DISABLE KEYS */;
INSERT INTO `card_transactions` VALUES (4,'done','redeem',10,NULL,2,1),(9,'done','redeem',85,NULL,2,2),(10,'done','redeem',25,NULL,2,2);
/*!40000 ALTER TABLE `card_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cards`
--

DROP TABLE IF EXISTS `cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` varchar(255) DEFAULT NULL,
  `balance` float DEFAULT '0',
  `card_product_id` int(11) DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cards_on_card_product_id` (`card_product_id`),
  KEY `index_cards_on_customer_id` (`customer_id`),
  CONSTRAINT `fk_rails_778182f614` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_rails_896213979b` FOREIGN KEY (`card_product_id`) REFERENCES `card_products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3468 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cards`
--

LOCK TABLES `cards` WRITE;
/*!40000 ALTER TABLE `cards` DISABLE KEYS */;
INSERT INTO `cards` VALUES (0,NULL,0,NULL,NULL),(1,'expired',-10,NULL,NULL),(2,'expired',-110,NULL,NULL),(23,NULL,0,NULL,NULL),(63,NULL,0,NULL,NULL),(3467,NULL,0,NULL,NULL);
/*!40000 ALTER TABLE `cards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('1');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stores`
--

DROP TABLE IF EXISTS `stores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `store_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stores`
--

LOCK TABLES `stores` WRITE;
/*!40000 ALTER TABLE `stores` DISABLE KEYS */;
/*!40000 ALTER TABLE `stores` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-12-09 12:12:00
