-- MySQL dump 10.13  Distrib 5.5.31, for debian6.0 (x86_64)
--
-- Host: localhost    Database: valegro_subscriptus_co
-- ------------------------------------------------------
-- Server version	5.5.31-log

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
-- Table structure for table `archived_publications`
--

DROP TABLE IF EXISTS `archived_publications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archived_publications` (
  `id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `publication_image_file_name` varchar(255) DEFAULT NULL,
  `publication_image_content_type` varchar(255) DEFAULT NULL,
  `publication_image_file_size` int(11) DEFAULT NULL,
  `publication_image_updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `forgot_password_link` varchar(255) DEFAULT NULL,
  `default_renewal_offer_id` int(11) DEFAULT NULL,
  `template_name` varchar(255) DEFAULT NULL,
  `custom_domain` varchar(255) DEFAULT NULL,
  `capabilities` int(11) NOT NULL DEFAULT '0',
  `terms_url` varchar(255) DEFAULT NULL,
  `from_email_address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_archived_publications_on_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archived_publications`
--

LOCK TABLES `archived_publications` WRITE;
/*!40000 ALTER TABLE `archived_publications` DISABLE KEYS */;
INSERT INTO `archived_publications` VALUES (1,'Archived','Archived Publications',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL);
/*!40000 ALTER TABLE `archived_publications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archived_subscriptions`
--

DROP TABLE IF EXISTS `archived_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archived_subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `offer_id` int(11) DEFAULT NULL,
  `publication_id` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `card_number` varchar(255) DEFAULT NULL,
  `card_expiration` varchar(255) DEFAULT NULL,
  `payment_method` varchar(255) DEFAULT NULL,
  `price` decimal(10,0) DEFAULT NULL,
  `auto_renew` tinyint(1) DEFAULT NULL,
  `state_updated_at` datetime DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `source_id` int(11) DEFAULT NULL,
  `referrer` text,
  `solus` tinyint(1) DEFAULT '0',
  `weekender` tinyint(1) DEFAULT '1',
  `pending` varchar(255) DEFAULT NULL,
  `state_expires_at` datetime DEFAULT NULL,
  `term_length` int(11) DEFAULT NULL,
  `concession` tinyint(1) DEFAULT '0',
  `pending_action_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archived_subscriptions`
--

LOCK TABLES `archived_subscriptions` WRITE;
/*!40000 ALTER TABLE `archived_subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `archived_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_log_entries`
--

DROP TABLE IF EXISTS `audit_log_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audit_log_entries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log_entries`
--

LOCK TABLES `audit_log_entries` WRITE;
/*!40000 ALTER TABLE `audit_log_entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit_log_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delayed_jobs`
--

DROP TABLE IF EXISTS `delayed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) DEFAULT '0',
  `attempts` int(11) DEFAULT '0',
  `handler` text,
  `last_error` text,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `delayed_jobs_priority` (`priority`,`run_at`)
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delayed_jobs`
--

LOCK TABLES `delayed_jobs` WRITE;
/*!40000 ALTER TABLE `delayed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `delayed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gift_offers`
--

DROP TABLE IF EXISTS `gift_offers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gift_offers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `offer_id` int(11) DEFAULT NULL,
  `gift_id` int(11) DEFAULT NULL,
  `included` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gift_offers`
--

LOCK TABLES `gift_offers` WRITE;
/*!40000 ALTER TABLE `gift_offers` DISABLE KEYS */;
INSERT INTO `gift_offers` VALUES (1,1,1,1,'2013-09-21 22:52:43','2013-09-21 22:52:43'),(6,2,2,0,'2013-09-23 11:33:47','2013-09-23 11:33:47'),(9,2,3,0,'2013-09-23 11:48:44','2013-09-23 11:48:44'),(10,3,2,1,'2013-09-24 01:35:18','2013-09-24 01:35:18'),(11,3,3,1,'2013-09-24 01:35:27','2013-09-24 01:35:27');
/*!40000 ALTER TABLE `gift_offers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gifts`
--

DROP TABLE IF EXISTS `gifts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gifts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `gift_image_file_name` varchar(255) DEFAULT NULL,
  `gift_image_content_type` varchar(255) DEFAULT NULL,
  `gift_image_file_size` int(11) DEFAULT NULL,
  `gift_image_updated_at` datetime DEFAULT NULL,
  `on_hand` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gifts`
--

LOCK TABLES `gifts` WRITE;
/*!40000 ALTER TABLE `gifts` DISABLE KEYS */;
INSERT INTO `gifts` VALUES (1,'Wordpress Plain','Unmodified latest version Wordpress with standard template, bundled with Subscriptus Portal.','wp1.png','image/png',4914,'2013-09-23 11:47:38',9997,'2012-08-20 11:06:36','2013-09-23 11:47:38'),(2,'Campaign Master Integration','Integration with Traction Digital','traction_logo.png','image/png',15375,'2013-09-23 11:32:36',1000,'2013-09-23 11:32:36','2013-09-23 11:32:36'),(3,'Custom Designed Wordpress Integration','Subscriptus integrated with custom designed Wordpress. ','wordpress.png','image/png',5625,'2013-09-23 11:48:01',10000,'2013-09-23 11:41:25','2013-09-24 01:30:15');
/*!40000 ALTER TABLE `gifts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `offer_terms`
--

DROP TABLE IF EXISTS `offer_terms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `offer_terms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `offer_id` int(11) DEFAULT NULL,
  `price` decimal(10,0) DEFAULT NULL,
  `months` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `concession` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `offer_terms`
--

LOCK TABLES `offer_terms` WRITE;
/*!40000 ALTER TABLE `offer_terms` DISABLE KEYS */;
INSERT INTO `offer_terms` VALUES (1,1,100,12,'2012-08-20 12:03:01','2012-08-20 12:03:01',0),(2,2,360,12,'2013-09-21 22:58:06','2013-09-21 22:58:06',0),(3,3,36000,12,'2013-09-24 01:33:39','2013-09-24 01:33:39',0);
/*!40000 ALTER TABLE `offer_terms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `offers`
--

DROP TABLE IF EXISTS `offers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `offers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `publication_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `expires` datetime DEFAULT NULL,
  `auto_renews` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `trial` tinyint(1) DEFAULT '0',
  `primary_offer` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_offers_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `offers`
--

LOCK TABLES `offers` WRITE;
/*!40000 ALTER TABLE `offers` DISABLE KEYS */;
INSERT INTO `offers` VALUES (1,1,'1 Year Subscriptus Portal Basic','2014-06-30 00:00:00',1,'2012-06-30 00:00:00','2013-09-21 23:02:41',1,1),(2,2,'1 Year Subscriptus Portal Premium','2014-06-30 00:00:00',1,'2013-09-21 22:58:06','2013-09-23 11:29:35',0,0),(3,3,'1 Year Subscriptus Enterprise','2014-06-30 00:00:00',1,'2013-09-24 01:33:39','2013-09-24 01:33:39',0,0);
/*!40000 ALTER TABLE `offers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) DEFAULT NULL,
  `gift_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` VALUES (1,1,1,'2013-09-22 01:24:29','2013-09-22 01:24:29'),(2,2,1,'2013-09-22 01:35:30','2013-09-22 01:35:30'),(3,3,1,'2013-09-22 09:33:48','2013-09-22 09:33:48');
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `state_updated_at` datetime DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `subscription_id` int(11) DEFAULT NULL,
  `has_delivery_address` tinyint(1) NOT NULL DEFAULT '0',
  `firstname` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone_number` varchar(255) DEFAULT NULL,
  `address_1` varchar(255) DEFAULT NULL,
  `address_2` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `address_state` varchar(255) DEFAULT NULL,
  `postcode` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,13,'2013-09-22 01:24:29','2013-09-22 01:25:31','2013-09-22 01:25:31','completed',2,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(2,14,'2013-09-22 01:35:30','2013-09-22 01:35:30','2013-09-22 01:35:30','pending',3,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(3,15,'2013-09-22 09:33:48','2013-09-22 09:33:48','2013-09-22 09:33:48','pending',4,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `card_number` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `card_expiry_date` datetime DEFAULT NULL,
  `amount` decimal(10,0) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `payment_type` varchar(255) DEFAULT NULL,
  `reference` varchar(255) DEFAULT NULL,
  `subscription_action_id` int(11) DEFAULT NULL,
  `processed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,NULL,NULL,NULL,NULL,100,'2013-09-22 01:17:11','2013-09-22 01:24:29','direct_debit','paid',1,'2013-09-22 01:24:29'),(2,NULL,NULL,NULL,NULL,100,'2013-09-22 01:26:16','2013-09-22 01:35:30','direct_debit','paid',2,'2013-09-22 01:35:30'),(3,NULL,NULL,NULL,NULL,100,'2013-09-22 09:31:19','2013-09-22 09:33:48','direct_debit','paid',3,'2013-09-22 09:33:48');
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `publications`
--

DROP TABLE IF EXISTS `publications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `publications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `publication_image_file_name` varchar(255) DEFAULT NULL,
  `publication_image_content_type` varchar(255) DEFAULT NULL,
  `publication_image_file_size` int(11) DEFAULT NULL,
  `publication_image_updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `forgot_password_link` varchar(255) DEFAULT NULL,
  `default_renewal_offer_id` int(11) DEFAULT NULL,
  `template_name` varchar(255) DEFAULT NULL,
  `custom_domain` varchar(255) DEFAULT NULL,
  `capabilities` int(11) NOT NULL DEFAULT '0',
  `terms_url` varchar(255) DEFAULT NULL,
  `from_email_address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_publications_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `publications`
--

LOCK TABLES `publications` WRITE;
/*!40000 ALTER TABLE `publications` DISABLE KEYS */;
INSERT INTO `publications` VALUES (1,'Subscriptus Basic','Basic Member & Subscriber Management Online Portal.','subscriptus1.gif','image/gif',2910,'2013-09-23 10:38:59','2012-06-30 00:00:00','2013-09-23 10:39:00','http://valegro.subscriptus.com.au/wp-login.php?action=lostpassword',1,'default','subscriptus.co',7,'http://valegro.subscriptus.com.au/about/terms-conditions/','no_reply@valegro.subscriptus.com.au'),(2,'Subscriptus Premium','Premium Member & Subscriber Management Online Portal.','subscriptus2.gif','image/gif',3336,'2013-09-23 10:38:38','2013-09-23 10:38:38','2013-09-24 01:31:01','http://valegro.subscriptus.com.au/wp-login.php?action=lostpassword',2,'default','subscriptus.co',5,'http://valegro.subscriptus.com.au/about/terms-conditions/','no_reply@valegro.subscriptus.com.au'),(3,'Subscriptus Enterprise','Bespoke and tailored made Member & Subscriber Management system. Integrated with your system requirements and incorporating your business rules.','subscriptus5.gif','image/gif',3340,'2013-09-23 10:43:48','2013-09-23 10:43:37','2013-09-23 10:43:49','http://valegro.subscriptus.com.au/wp-login.php?action=lostpassword',NULL,'default','subscriptus.co',5,'http://valegro.subscriptus.com.au/about/terms-conditions/','no_reply@subscriptus.co');
/*!40000 ALTER TABLE `publications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scheduled_suspensions`
--

DROP TABLE IF EXISTS `scheduled_suspensions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scheduled_suspensions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_date` date DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `subscription_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `state` varchar(255) NOT NULL,
  `state_updated_at` datetime DEFAULT NULL,
  `state_expires_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scheduled_suspensions`
--

LOCK TABLES `scheduled_suspensions` WRITE;
/*!40000 ALTER TABLE `scheduled_suspensions` DISABLE KEYS */;
/*!40000 ALTER TABLE `scheduled_suspensions` ENABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) NOT NULL,
  `data` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sources`
--

DROP TABLE IF EXISTS `sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sources`
--

LOCK TABLES `sources` WRITE;
/*!40000 ALTER TABLE `sources` DISABLE KEYS */;
INSERT INTO `sources` VALUES (1,'Subscriptus Portal','Subscriptus subscribe page','1','2012-08-20 10:32:10','2012-08-20 10:32:10');
/*!40000 ALTER TABLE `sources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscription_actions`
--

DROP TABLE IF EXISTS `subscription_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscription_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `offer_name` varchar(255) DEFAULT NULL,
  `term_length` int(11) DEFAULT NULL,
  `source_id` int(11) DEFAULT NULL,
  `subscription_id` int(11) DEFAULT NULL,
  `applied_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `renewal` tinyint(1) DEFAULT '0',
  `old_expires_at` datetime DEFAULT NULL,
  `new_expires_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscription_actions`
--

LOCK TABLES `subscription_actions` WRITE;
/*!40000 ALTER TABLE `subscription_actions` DISABLE KEYS */;
INSERT INTO `subscription_actions` VALUES (1,'1 Year Subscriptus Portal Basic',12,NULL,2,'2013-09-22 01:24:29','2013-09-22 01:17:11','2013-09-22 01:24:29',0,NULL,'2014-09-22 01:24:29'),(2,'1 Year Subscriptus Portal Basic',12,NULL,3,'2013-09-22 01:35:30','2013-09-22 01:26:16','2013-09-22 01:35:30',0,NULL,'2014-09-22 01:35:30'),(3,'1 Year Subscriptus Portal Basic',12,NULL,4,'2013-09-22 09:33:48','2013-09-22 09:31:19','2013-09-22 09:33:48',0,NULL,'2014-09-22 09:33:48');
/*!40000 ALTER TABLE `subscription_actions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscription_gifts`
--

DROP TABLE IF EXISTS `subscription_gifts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscription_gifts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subscription_action_id` int(11) DEFAULT NULL,
  `gift_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `included` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscription_gifts`
--

LOCK TABLES `subscription_gifts` WRITE;
/*!40000 ALTER TABLE `subscription_gifts` DISABLE KEYS */;
INSERT INTO `subscription_gifts` VALUES (1,1,1,'2013-09-22 01:17:11','2013-09-22 01:17:11',0),(2,2,1,'2013-09-22 01:26:16','2013-09-22 01:26:16',0),(3,3,1,'2013-09-22 09:31:19','2013-09-22 09:31:19',0);
/*!40000 ALTER TABLE `subscription_gifts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscription_invoices`
--

DROP TABLE IF EXISTS `subscription_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscription_invoices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subscription_id` int(11) DEFAULT NULL,
  `amount` float DEFAULT NULL,
  `amount_due` float DEFAULT NULL,
  `invoice_number` varchar(255) DEFAULT NULL,
  `harvest_invoice_id` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `state_updated_at` date DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscription_invoices`
--

LOCK TABLES `subscription_invoices` WRITE;
/*!40000 ALTER TABLE `subscription_invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscription_invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscription_log_entries`
--

DROP TABLE IF EXISTS `subscription_log_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscription_log_entries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subscription_id` int(11) DEFAULT NULL,
  `source_id` int(11) DEFAULT NULL,
  `old_state` varchar(255) DEFAULT NULL,
  `new_state` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscription_log_entries`
--

LOCK TABLES `subscription_log_entries` WRITE;
/*!40000 ALTER TABLE `subscription_log_entries` DISABLE KEYS */;
INSERT INTO `subscription_log_entries` VALUES (1,1,NULL,NULL,'active','Expiry Date set to 22/09/13','2013-09-22 01:14:09','2013-09-22 01:14:09'),(2,2,NULL,NULL,'pending','','2013-09-22 01:17:12','2013-09-22 01:17:12'),(3,2,NULL,NULL,NULL,'','2013-09-22 01:17:17','2013-09-22 01:17:17'),(4,2,NULL,NULL,NULL,'Expiry Date set to 22/09/14','2013-09-22 01:24:29','2013-09-22 01:24:29'),(5,2,NULL,'pending','active','$100.00 by Direct debit (Ref: paid)','2013-09-22 01:24:29','2013-09-22 01:24:29'),(6,3,NULL,NULL,'pending','','2013-09-22 01:26:16','2013-09-22 01:26:16'),(7,3,NULL,NULL,NULL,'','2013-09-22 01:26:21','2013-09-22 01:26:21'),(8,3,NULL,NULL,NULL,'Expiry Date set to 22/09/14','2013-09-22 01:35:30','2013-09-22 01:35:30'),(9,3,NULL,'pending','active','$100.00 by Direct debit (Ref: paid)','2013-09-22 01:35:30','2013-09-22 01:35:30'),(10,4,NULL,NULL,'pending','','2013-09-22 09:31:20','2013-09-22 09:31:20'),(11,4,NULL,NULL,NULL,'','2013-09-22 09:31:41','2013-09-22 09:31:41'),(12,4,NULL,NULL,NULL,'Expiry Date set to 22/09/14','2013-09-22 09:33:48','2013-09-22 09:33:48'),(13,4,NULL,'pending','active','$100.00 by Direct debit (Ref: paid)','2013-09-22 09:33:48','2013-09-22 09:33:48'),(14,5,NULL,NULL,'trial','Expiry Date set to 13/10/13','2013-09-22 09:49:13','2013-09-22 09:49:13'),(15,6,NULL,NULL,'trial','Expiry Date set to 13/10/13','2013-09-22 16:19:07','2013-09-22 16:19:07'),(16,7,NULL,NULL,'trial','Expiry Date set to 14/10/13','2013-09-23 04:13:25','2013-09-23 04:13:25');
/*!40000 ALTER TABLE `subscription_log_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscription_payments`
--

DROP TABLE IF EXISTS `subscription_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscription_payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subscription_id` int(11) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `success` tinyint(1) DEFAULT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `message` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `subscription_invoice_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscription_payments`
--

LOCK TABLES `subscription_payments` WRITE;
/*!40000 ALTER TABLE `subscription_payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscription_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscriptions`
--

DROP TABLE IF EXISTS `subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `offer_id` int(11) DEFAULT NULL,
  `publication_id` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `card_number` varchar(255) DEFAULT NULL,
  `card_expiration` varchar(255) DEFAULT NULL,
  `payment_method` varchar(255) DEFAULT NULL,
  `price` decimal(10,0) DEFAULT NULL,
  `auto_renew` tinyint(1) DEFAULT NULL,
  `state_updated_at` datetime DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `source_id` int(11) DEFAULT NULL,
  `referrer` text,
  `solus` tinyint(1) DEFAULT '0',
  `weekender` tinyint(1) DEFAULT '1',
  `pending` varchar(255) DEFAULT NULL,
  `state_expires_at` datetime DEFAULT NULL,
  `term_length` int(11) DEFAULT NULL,
  `concession` tinyint(1) DEFAULT '0',
  `pending_action_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `subscriptions_publication_id` (`publication_id`),
  KEY `index_subscriptions_on_publication_id` (`publication_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscriptions`
--

LOCK TABLES `subscriptions` WRITE;
/*!40000 ALTER TABLE `subscriptions` DISABLE KEYS */;
INSERT INTO `subscriptions` VALUES (1,12,NULL,1,'active',NULL,NULL,NULL,NULL,NULL,'2013-09-22 01:14:09','2013-09-22 00:00:00','2013-09-22 01:14:09','2013-09-22 01:14:09',NULL,NULL,0,1,NULL,NULL,NULL,0,NULL),(2,13,1,1,'active',NULL,NULL,NULL,NULL,NULL,'2013-09-22 01:24:29','2014-09-22 01:24:29','2013-09-22 01:17:11','2013-09-22 01:24:29',NULL,NULL,1,1,'payment','2014-09-22 01:24:29',NULL,0,NULL),(3,14,1,1,'active',NULL,NULL,NULL,NULL,NULL,'2013-09-22 01:35:30','2014-09-22 01:35:30','2013-09-22 01:26:16','2013-09-22 01:35:30',NULL,NULL,0,1,'payment','2014-09-22 01:35:30',NULL,0,NULL),(4,15,1,1,'active',NULL,NULL,NULL,NULL,NULL,'2013-09-22 09:33:48','2014-09-22 09:33:48','2013-09-22 09:31:19','2013-09-22 09:33:48',NULL,NULL,0,1,'payment','2014-09-22 09:33:48',NULL,0,NULL),(5,16,NULL,1,'trial',NULL,NULL,NULL,NULL,NULL,'2013-09-22 09:49:12','2013-10-13 09:49:12','2013-09-22 09:49:12','2013-09-22 09:49:12',0,'http://offer.gimmesubscribers.com/my-subscriptions',NULL,1,NULL,NULL,NULL,0,NULL),(6,17,NULL,1,'trial',NULL,NULL,NULL,NULL,NULL,'2013-09-22 16:19:07','2013-10-13 16:19:07','2013-09-22 16:19:07','2013-09-22 16:19:07',0,'http://offer.gimmesubscribers.com/my-subscriptions',NULL,1,NULL,NULL,NULL,0,NULL),(7,18,NULL,1,'trial',NULL,NULL,NULL,NULL,NULL,'2013-09-23 04:13:24','2013-10-14 04:13:24','2013-09-23 04:13:24','2013-09-23 04:13:24',0,'http://offer.gimmesubscribers.com/my-subscriptions',NULL,1,NULL,NULL,NULL,0,NULL);
/*!40000 ALTER TABLE `subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temp_ids`
--

DROP TABLE IF EXISTS `temp_ids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `temp_ids` (
  `id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temp_ids`
--

LOCK TABLES `temp_ids` WRITE;
/*!40000 ALTER TABLE `temp_ids` DISABLE KEYS */;
/*!40000 ALTER TABLE `temp_ids` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transaction_logs`
--

DROP TABLE IF EXISTS `transaction_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transaction_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recurrent_id` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `money` decimal(10,0) DEFAULT NULL,
  `success` tinyint(1) DEFAULT NULL,
  `message` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `subscription_id` int(11) DEFAULT NULL,
  `order_num` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaction_logs`
--

LOCK TABLES `transaction_logs` WRITE;
/*!40000 ALTER TABLE `transaction_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `transaction_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `firstname` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone_number` varchar(255) DEFAULT NULL,
  `address_1` varchar(255) DEFAULT NULL,
  `address_2` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `postcode` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `login` varchar(255) NOT NULL,
  `crypted_password` varchar(255) NOT NULL,
  `password_salt` varchar(255) NOT NULL,
  `persistence_token` varchar(255) NOT NULL,
  `login_count` int(11) NOT NULL DEFAULT '0',
  `last_request_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `current_login_at` datetime DEFAULT NULL,
  `last_login_ip` varchar(255) DEFAULT NULL,
  `current_login_ip` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `role` varchar(255) DEFAULT NULL,
  `admin` tinyint(1) DEFAULT NULL,
  `auto_created` tinyint(1) DEFAULT NULL,
  `hear_about` varchar(255) DEFAULT NULL,
  `company` varchar(255) DEFAULT NULL,
  `valid_concession_holder` tinyint(1) DEFAULT '0',
  `payment_gateway_token` varchar(255) DEFAULT NULL,
  `gender` varchar(255) DEFAULT NULL,
  `perishable_token` varchar(255) NOT NULL DEFAULT '',
  `next_login_redirect` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  KEY `user_email_index` (`email`),
  KEY `index_users_on_perishable_token` (`perishable_token`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Subscriptus','Administrator','admin@subscriptus.co','+61 3 9018 5710','22 William Street','','Melbourne','act','3000','Australia','Mr','admin','21dbf8b4268d5af4b7226d24c4b41e24b4bf4f6e2201990a87fa27e29b06c03bb5f8b24575cc33abf106abc3735159c91e0d725727c21a88290c277b20f4a09c','ViQupGazrPRc3vSGPILz','1e8b51dff1edf957732ef852930c1059c3f87efeb52d24ec834d7f37f7a746046467e736d5dcd628b8fd4fe3947945f5cc6b29ee16e9594fabc126cefd93dccd',50,'2013-10-25 04:45:10','2013-10-25 04:44:57','2013-10-25 04:45:08','192.168.1.4','192.168.1.4','2012-08-20 06:38:53','2013-10-25 04:45:10','admin',1,NULL,NULL,NULL,0,NULL,'male','5IVfJJlnR19DNZU7zVcz',NULL),(11,'Pieter','Coetzee','sales@subscriptus.com.au','0390185710','Ground Floor, 22 William Street','','Melbourne','vic','3000','Australia','Mr','cef75e82370f222694db684fb1f78793','e129c5c8c658de00f84f589c1ba649cc3dfe6f70beb1ea83f964b43e05e683a1ddc3dc49eed65ba69f89e2f24add73ad446459a93d678722c60cc7a8bbc125a0','nhuxcpdFMRqwGGgDK2','c4d8e47c4899e56a05487d8d0219a651e51e04de121b11cc5692dc409cd9d679fb9a5553fd970a3db8306e531e9cd73dadae3c5e5778cff021ea6cbd7ead7878',0,NULL,NULL,NULL,NULL,NULL,'2013-09-22 00:59:28','2013-09-22 00:59:28','subscriber',NULL,NULL,NULL,'Subscriptus Pty Ltd',0,NULL,'male','HESbCMieSUk3zX8cFpkI',NULL),(12,'Pieter','Coetzee','sales@valegro.com.au','0390187510','Ground Floor, 22 William Street','','Melbourne','vic','3000','Australia','Mr','c10be66798291b47d6cbdde9abaff751','b6c3bf1d84724ec244af441f6e30c7cc7cc0c338aaec0f11ead392d8548df8a1800b2d30ee762a4ad526caf77f0d3b278dd6976aeaa8949d495b444f013cf754','rP24UGmprqA3zZdhZe2S','7315c91a4171febdd70969dc468eb8ad5c0afd2efb310d442999931c721f66cc2a85338d0f26dd063a1b3d918883ea83ca6f606f3dcafb94687b95e7b1677971',0,NULL,NULL,NULL,NULL,NULL,'2013-09-22 01:13:48','2013-09-22 01:14:09','subscriber',NULL,NULL,NULL,'Valegro Pty Ltd',0,NULL,'male','QdNdQJtTKdyUDP9Xk9q',NULL),(13,'Pieter','Coetzee','pieter@valegro.com.au','0390187510','Ground Floor, 22 William Street','','Melbourne','vic','3000','Australia','Mr','41f2a889b852a293e6e5c2115f6046e4','5a1cb05f88e6d1182f1a3550384ab57481c0f32570a0c03ced1251b5837405d87a5b840c2109e2fa68799bdf7e6c8c42544b1950e0b98fe82988dade6203250e','lUr6auuoF12uTBBMgnZ','a0a12f5ca1903f66691b6f258cc18f62c50860e599230d3759955fe1df728d1dba38db83119c566e7c6a9439bb979e978dd3fefe4e364eee45b4980e09696a32',7,'2013-10-25 04:41:41','2013-09-23 11:28:44','2013-10-25 04:41:36','114.111.138.127','192.168.1.4','2013-09-22 01:17:11','2013-10-25 04:41:41','subscriber',NULL,NULL,NULL,'Valegro Pty Ltd',0,NULL,'male','5jA5PrgUJq0a9BkIXM8',NULL),(14,'Pieter','Coetzee','accounts@valegro.com.au','0390185710','Ground Floor, 22 William Street','','Melbourne','vic','3000','Australia','Mr','1c7d356039b2cfb89b9dde5e15aaf93a','503db800a59e0625fc3007b1af931351d3f90a9f469e484d053ba539b034ff2aa4357d7a3ef1dde8335eed4f16d71eccac591f630b8648169584d9224e4bf043','VrLjkIpssft04ZQUrps','ad70c7e8b01617c64243751f618cca652c78283d41c2cec232bf4dd83d93cfd7b64971b5ae36c2d0b245cd43b948e3c4f7b676c2598129c26b18c13543d5c4ba',2,'2013-09-23 03:21:13','2013-09-23 03:20:20','2013-09-23 03:20:53','113.52.239.246','113.52.239.246','2013-09-22 01:26:16','2013-09-23 03:21:13','subscriber',NULL,NULL,NULL,'',0,NULL,'male','e4jlsHY9iunveSW0otrs',NULL),(15,'Pieter','Coetzee','pieter@subscriptus.com.au','0390185710','Ground Floor, 22 William Street','','Melbourne','vic','3000','Australia','Mr','57f348d376d49d08cb81cb5b23af97d5','ccee7ec7be9cab12bda21dfbb16b2fa48bf339d0017463320d8d2420faeb4b2563e3e2ba4b4bcd9cfa4dac1cafd9c010e6fa54f0217300328893d4984d7cfb50','5SMfrXbRbC9vS6KllG3z','2900160998b7cc78e03925f258052c0d6444ac2fb0b895164d945ec9147b6122d7e7671c0469c8385222d261c5f9aae24b9e5d4fd123f1f31e9e00d7a8771323',0,NULL,NULL,NULL,NULL,NULL,'2013-09-22 09:31:19','2013-09-22 09:33:48','subscriber',NULL,NULL,NULL,'Subscriptus Pty Ltd',0,NULL,'male','0Jq2BL85NxYGhII24K2x',NULL),(16,'Pieter','Coetzee','pieter.coetzee@valegro.com.au',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'cbf76779d31edcba9858368bb50cc0ac','3fed36e0acf44edd82556cc94c4b8ff89b7313e4a79fc4176662a1305e08ce6def9c92431915413dc494dded9f451f8b570262c7bd3a907954c5807d307895a6','q6rENubQxNfDUJUQSfzE','641877fb399394dcf9c7cf9f06dc82a914533465ed9dcb6d47b0aaa252bd414c12be1df2e930650b089ba81af9b21c01fe0aeafe40520b426558f0c523d5540e',1,'2013-09-22 09:49:12',NULL,'2013-09-22 09:49:12',NULL,'54.241.34.25','2013-09-22 09:49:12','2013-09-22 09:49:12','subscriber',NULL,1,NULL,NULL,0,NULL,NULL,'N3TmXBljRVbDMGCL4eD',NULL),(17,'Pieter','Coetzee','accounts@subscriptus.com.au',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'97c99c91061c18f05dda43b1e30f16b8','1c4814a6a7fea91f19211dd060a5c844f6d10894e050510516f15a5cd12a00ca8103e88f89d874a150cc8c8358a0cba97f38f2ebf45dd706f8c4453cb40648c7','yAUqauajhXWEoHrau1o','cb3d6fd4aeb0517850295fe61843e857d6addffd3b8fb1b7fbcce1907140c13b0e31e53e4ae7053518ea3cecdce4631a3544ee0f9b3d0f5c0d7ed6a9f4484101',5,'2013-09-22 16:58:57','2013-09-22 16:56:35','2013-09-22 16:58:48','110.174.94.4','110.174.94.4','2013-09-22 16:19:07','2013-09-22 16:58:57','subscriber',NULL,1,NULL,NULL,0,NULL,NULL,'AGccv2SwsiwCnDVFS9Z',NULL),(18,'Pieter','Coetzee','admin@valegro.com.au',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'0a2c18099ccffc739ab7613a1ed42178','f331e9d82ead28789edea2406bda17c303c7abb06c6207b12a66cee1fbb393ef72052b4adffbbad478176aa113bc55d6e0e4ccd7ee28e3b3ff33a50814fad62d','Ikr5eMWDZL6i0WHeyL','1dc6f135a42e0fb923506c924ea33f1ab69593127a3795080fe7495f8aeead82009287030e1a64f6fbeac4b3cf9aa385b535c8e82c36aec1f9f67a01aba9a613',2,'2013-09-23 04:21:07','2013-09-23 04:13:24','2013-09-23 04:15:13','54.241.34.25','114.111.138.127','2013-09-23 04:13:24','2013-09-23 04:21:07','subscriber',NULL,1,NULL,NULL,0,NULL,NULL,'kgSU9z65nrbsc7yhnk',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-10-25 15:46:36
