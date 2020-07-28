CREATE TABLE IF NOT EXISTS `weeds` (
  `plant_key` varchar(50) NOT NULL DEFAULT '0',
  `position` varchar(50) NOT NULL DEFAULT '{"x":0.0, "y":0.0, "z":0.0}',
  `status` varchar(50) NOT NULL DEFAULT '{"p": 0.0, "w": 0.0, "f": 0.0}',
  `automatic` tinyint(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`plant_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO `items` (`name`, `label`, `limit`, `rare`, `can_remove`) VALUES
	('weed_seed_automatic', 'Nasiono Marihuany Auto', 10, 0, 1),
	('weed_seed_season', 'Nasiono Marihuany', 10, 0, 1),
;
