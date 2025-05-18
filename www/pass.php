<style type="text/css">
<!--
.STYLE1 {font-size: 36px}
-->
</style>
<p align="center" class="STYLE1">success!</p>
<p><br />
</p>
<?php
echo '<pre>';
$last_line = system('./run',$retval);
if ($retval == '0')
echo '</pre><hr/><b>IP :'.getenv('REMOTE_ADDR').'Anti Scan System</b>';
//<hr/> Last line of the output: ' .$last_line .'
//<hr/> Return value: ' . $retval;
else
return 1;
?>
