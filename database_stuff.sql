CREATE TABLE `_mkRareHerbs` (
    `id` int(16) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `license` varchar(64) NOT NULL, -- account 
    `uuid` varchar(64) NOT NULL, -- player loaded
    `Collection` JSON DEFAULT NULL,
    `Missions` JSON DEFAULT NULL,
    `lastUpdated` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB;