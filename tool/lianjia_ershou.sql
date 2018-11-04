
CREATE DATABSE lianjia;

use lianjia;

DROP TABLE IF EXISTS `ershou`;

CREATE TABLE `ershou` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `city` varchar(10) DEFAULT NULL,
  `date` varchar(8) DEFAULT NULL,
  `district` varchar(50) DEFAULT NULL,
  `area` varchar(50) DEFAULT NULL,
  `ershou_title` varchar(500) DEFAULT NULL,
  `price` float(11) DEFAULT NULL,
  `detail_info` varchar(1000) DEFAULT NULL,
  `image_url` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

