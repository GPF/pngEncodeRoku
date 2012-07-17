<?php
        # This script receives a binary file uploaded from a Corona
        # app.  If you are uploading something other than a PNG,
        # you will want to change that here:
        $filename = "myFile-" . time() . ".png";

        $pngdata = file_get_contents("php://input");
        if( isset( $pngdata ) ) {
                $img_file = fopen ($filename, 'wb');
                fwrite ($img_file, $pngdata );
                fclose ($img_file);
                echo "Success.";
                }
        else {
                echo "Failure.";
                }
?>