CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `users` AS 

select 
`crm_emailaddress`.`Email` as email, 
convert(`active_contactversion`.`Title` using utf8) AS title, 
concat(
  '\n{\n  \"firstname\":\"',`active_contactversion`.`FirstName`,
  '\",\n  \"lastname\":\"',`active_contactversion`.`LastName`,
  '\",\n  \"title\":\"',convert(`active_contactversion`.`Title` using utf8),
  '\",\n  \"login\":\"',convert(`active_contactversion`.`Username` using utf8),
  '\",\n  \"company\":\"',`active_contactversion`.`Company`,
  '\",\n  \"address_1":\"',`crm_address`.`Street1`,
  '\",\n  \"address_2\":\"',`crm_address`.`Street2`,
  '\",\n  \"city\":\"',`crm_address`.`Suburb`,
  '\",\n  \"state\":\"',`crm_address`.`State`,
  '\",\n  \"postcode\":\"',convert(`crm_address`.`Postcode` using utf8),
  '\",\n  \"country\":\"',convert(`crm_address`.`Country` using utf8),
  '\",\n  \"phone\":\"',convert(ifnull(`active_contactversion`.`WorkPhone`,ifnull(`active_contactversion`.`HomePhone`,`active_contactversion`.`MobilePhone`)) using utf8),
  '\",\n \"email\":\"',convert(`crm_emailaddress`.`Email` using utf8),
  '\"\n}\n') AS `user`,
  concat(
  '\n{\n  \"last_login_at\":\"',`active_contactversion`.`LastLoginDate`,
  '\",\n  \"last_login_ip\":\"',`active_contactversion`.`IpAddress`,
  '\",\n  \"created_at\":\"',`active_contactversion`.`DateCreated`,'\"\n }\n') AS `access`,
`active_contactversion`.`ContactId` AS `ContactId` 
from ((((`active_contactversion` 
join `crm_contactemailaddress` on((`active_contactversion`.`VersionId` = `crm_contactemailaddress`.`VersionId`))) 
join `crm_emailaddress` on((`crm_contactemailaddress`.`EmailAddressId` = `crm_emailaddress`.`EmailAddressId`))) 
join `crm_contactaddress` on((`active_contactversion`.`VersionId` = `crm_contactaddress`.`VersionId`))) 
join `crm_address` on((`crm_contactaddress`.`AddressId` = `crm_address`.`AddressId`))) 
where ((`crm_emailaddress`.`Status` = 1) and (`crm_address`.`MainContact` = 1))
