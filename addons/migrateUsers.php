<?php
  mysql_connect("172.16.14.162", "wordpress", "bfdc968a5e540a198f80a4eae2226dd3") or die(mysql_error());
 
  mysql_select_db("wordpress") or die(mysql_error());
 
  $result = mysql_query("select * from cmanager limit 10");

  
  while($row = mysql_fetch_assoc($result)){
    echo $row;
  }

?>
