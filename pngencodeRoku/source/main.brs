' Roku PNG encoder ported by Troy Davis(GPF)
' Takes RGBA ByteArray and encodes it as a png ByteArray

' Minimal PNG encoder to create PNG streams (and MIDP images) from RGBA arrays.
' 
' Copyright 2006-2009 Christian Fröschlin
'
' www.chrfr.de

Library "v30/bslCore.brs"

Function IsHD()
    di = CreateObject("roDeviceInfo")
    if di.GetDisplayType() = "HDTV" then return true
    return false
End Function

function main()

  backstop = CreateObject("roParagraphScreen")
  backstop.show()
  codes = bslUniversalControlEventCodes()
    if IsHD()
        screen=CreateObject("roScreen", true, 854, 480)  '
    else
        screen=CreateObject("roScreen", true)
    endif


    pixels = CreateObject("roByteArray")
    pixels=ROKURGBA()
	
    screen.Clear(&HFFFFFF)
    screen.SwapBuffers()
    
    ' bigbm=CreateObject("roBitmap", "pkg:/images/site_logo.jpg")

               '     stop
    'if bigbm = invalid
    '    print "bigbm create failed"
    '    stop
    'endif

   'screen.drawobject(20, 20, bigbm)
   'screen.SwapBuffers()
    
 ' Test PNGFB 
 

    'ad1=[asc("f"),asc("o")]
    'ad2=[asc("o")]
     
     'adl1=calcADLER32(ad1)
     'adl2=calcADLER32(ad2)

     'adlr3=ADLER32_Combine(adl1,adl2,1)

     'print "ADLER32= 0x02820145=0x"+rdINTtoHEX(adlr3)
  
    'Dim pixels[4*bigbm.Getwidth()*bigbm.getheight()]
    'apixels = CreateObject("roByteArray")
    'pixels = CreateObject("roByteArray")
    'pixels = bigbm.GetByteArray(0,0,320, 200)  

    'for y = 0 to bigbm.GetHeight()
    'for x=0 to bigbm.GetWidth()

    'apixel=bigbm.GetByteArray(x,y,1, 1)
    'print apixel.toHexString()	 
    'print apixel[0];",";apixel[1];",";apixel[2];",";apixel[3]
    
    'pixels.append(apixel)


    'end for
    'end for
    
    'tmp = rdTempFile(".png")
    'print "pixels File "+tmp    
    'pixels.writefile(tmp)
    
    'myurl=CreateObject("roUrlTransfer")
    'myurl.SetUrl("http://192.168.2.2/roku/upload.php")
    'myurl.AddHeader("Content-Type", "image/png")
    'myurl.PostFromFile(tmp)
    
    Print "Encoding PNG now"
    png = CreateObject("roByteArray")
    png = toPNG(160,69,pixels)
    print "PNG Count = "+ png.Count().ToStr()
    'tmp = "tmp:/hello.png" 
    tmp = rdTempFile(".png")
    print "File "+tmp    
    png.writefile(tmp)
    print "File "+tmp
    
  
    'myurl=CreateObject("roUrlTransfer")
    'myurl.SetUrl("http://192.168.2.2/roku/upload.php")
    'myurl.AddHeader("Content-Type", "image/png")
    'myurl.PostFromFile(tmp)
    
    'stop   

    
    newPNG=CreateObject("roBitmap", tmp)
    
    DeleteFile(tmp)
                
    if newPNG = invalid
        print "newPNG create failed"
        stop
    endif    


    'screen.drawobject(0, 0, bigbm)
    screen.drawobject(180, 90, newPNG)
    screen.SwapBuffers()    

    msgport = CreateObject("roMessagePort")
    screen.SetPort(msgport)
    
    

    pressedState = -1 ' If > 0, is the button currently in pressed state
    while true
	if pressedState = -1 then
	    msg=wait(0, msgport)   ' wait for a button press
	else
	    msg=wait(1, msgport)   ' wait for a button release or move in current pressedState direction 
	endif
        if type(msg)="roUniversalControlEvent" then
                keypressed = msg.GetInt()
                print "keypressed=";keypressed
                if keypressed=codes.BUTTON_BACK_PRESSED then
		        pressedState = -1
		        exit while
                end if
	else if msg = invalid then
                print "eventLoop timeout pressedState = "; pressedState

        end if
    end while
        
end function


 