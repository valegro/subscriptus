CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `cmailer`.`subscriptions` AS 

select `cmailer`.`crm_contactcontactlist`.`ContactId` AS `ContactId`,
group_concat(
  concat(
    '\n{\n  state:\'',`cmailer`.`list_subscriptions`.`state`,
    '\',\n  created_at:\'',ifnull(`cmailer`.`crm_contactcontactlist`.`DateCommences`,''),
    '\',\n  expires_at:\'',ifnull(`cmailer`.`crm_contactcontactlist`.`DateExpires`,''),
    '\',\n  publication:\'',`cmailer`.`list_subscriptions`.`publication`,
    '\',\n  price:\'',ifnull(`cmailer`.`crm_product`.`Price`,0),
    '\'\n  offer:\'',ifnull(`cmailer`.`list_subscriptions`.`offer`,''),
    '\',\n  source:\'',ifnull(`cmailer`.`list_subscriptions`.`source`,''),
    '\',\n  list:\'',`cmailer`.`crm_contactlist`.`Title`,
    '\',\n  status:\'',`cmailer`.`crm_contactcontactlist`.`Status`,
    '\',\n  auto_renew:\'',if(`cmailer`.`crm_contactcontactlist`.`RenewalImport`,1,0),
    '\'\n}\n'
  ) separator ','
) AS `subscriptions` 

from ((((`cmailer`.`crm_contactcontactlist` join `cmailer`.`crm_contact` 
on((`cmailer`.`crm_contactcontactlist`.`ContactId` = `cmailer`.`crm_contact`.`ContactId`))) 
left join `cmailer`.`crm_contactlist` 
on((`cmailer`.`crm_contactcontactlist`.`ContactListId` = `cmailer`.`crm_contactlist`.`ContactListId`))) 
left join `cmailer`.`list_subscriptions` on((`cmailer`.`crm_contactlist`.`Title` = convert(`cmailer`.`list_subscriptions`.`list` using utf8)))) 
left join `cmailer`.`crm_product` on((`cmailer`.`crm_contactcontactlist`.`ContactListId` = `cmailer`.`crm_product`.`ContactListId`))) 
where (`cmailer`.`crm_contactcontactlist`.`Status` = `cmailer`.`list_subscriptions`.`status`) group by `cmailer`.`crm_contactcontactlist`.`ContactId`
