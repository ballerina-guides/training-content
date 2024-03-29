CREATE DATABASE IF NOT EXISTS `movies`;

USE `movies`;

DROP TABLE IF EXISTS `Movie`;
DROP TABLE IF EXISTS `Director`;

CREATE TABLE `Director` (
	`id` VARCHAR(191) NOT NULL,
	`name` VARCHAR(191) NOT NULL,
	`birthYear` INT NOT NULL,
	PRIMARY KEY(`id`)
);

CREATE TABLE `Movie` (
	`id` VARCHAR(191) NOT NULL,
	`title` VARCHAR(191) NOT NULL,
	`year` INT NOT NULL,
	`directorId` VARCHAR(191) NOT NULL,
	FOREIGN KEY(`directorId`) REFERENCES `Director`(`id`),
	PRIMARY KEY(`id`)
);
