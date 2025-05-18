<?php

if($_POST){	
	$fpw= fopen("./passwd","r")or exit("Unable to open with write");
	for($i=0;!feof($fpw);$i++){
		$passwds = fgets($fpw);
		if($_POST["passwd"]."\n"==$passwds){
			$ip = getenv('REMOTE_ADDR');
			echo "YOUR REMOTE_ADDR IS :".$ip;
			echo "\nWRITING TO SYSTEM...\n";

			$file = fopen("ip","w")or exit("Unable to open with write");
			$newfp=NULL;
			fputs($file,$newfp);
			$contents = "iptables -I INPUT -s ".$ip." -j ACCEPT"."\n"
					//."service iptables save"."\n"
					//."service iptables restart"."\n"
													;
			fwrite($file,$contents);
			fclose($file);

			echo "<script language='javascript'>window.location.href='pass.php';</script>";
			return 0;
		}
	}
	echo "<b>WARMING: DO NOT TRY, IF YOU ARE NOT USER!</b>";
}
?>
<html>
<form action="index.php" method="post">
<div align="center">Passwd:       
  <input type="password" name="passwd" />
  <input type="submit" />
</div>
</html>
