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

'm.profiler = NewProfiler(1) 

'    pixels = CreateObject("roByteArray")
'    pixels2 = CreateObject("roByteArray")
'    pix=ROKURGBA()
'	For i=0 to pix.count()
'		pixels[i]=pix[i]
'
'	End For 
'
'    'pixels2.FromHexString(pixels)
'    pixs=pixels.toHexString()
'
'    'print pixels[0];",";pixels[1];",";pixels[2];",";pixels[3];",";pixels[4];",";pixels[5];",";pixels[6]
'    print pixs.left(160*8)+chr(10)+chr(13)
'    regfind="(.{"+(160*8).toStr()+"})"
'    print regfind+chr(10)+chr(13)
'    r = CreateObject("roRegex",regfind , "")
'    pixs=r.ReplaceAll(pixs, "\100")
'    
'    
'    
'    
'    pixs="00"+pixs.left(pixs.len()-2)
'    
'    print pixs.left(161*8)
'    pixels2.FromHexString(pixs)
'
'    'print pixels2[0];",";pixels2[1];",";pixels2[2];",";pixels2[3];",";pixels2[4];",";pixels2[5];",";pixels2[6]
'    
'    
'   'stop
    
    

    
    
    
    
    screen.Clear(&HFFFFFF)
    screen.SwapBuffers()
    
	bigbm=CreateObject("roBitmap", "pkg:/images/site_logo.png")

	if bigbm = invalid
		print "bigbm create failed"
	
 	endif

   screen.drawobject(0, 0, bigbm)
   'bigbm.Clear(&hFFFF)
   screen.SwapBuffers()
    
 ' Test PNGFB 
 

    'ad1=[asc("f"),asc("o")]
    'ad2=[asc("o")]
     
     'adl1=calcADLER32(ad1)
     'adl2=calcADLER32(ad2)

     'adlr3=ADLER32_Combine(adl1,adl2,1)

     'print "ADLER32= 0x02820145=0x"+rdINTtoHEX(adlr3)
  
    'Dim pixels[4*bigbm.Getwidth()*bigbm.getheight()]
    'apixels = CreateObject("roByteArray")
    
    pixels = CreateObject("roByteArray")
    apixels = CreateObject("roByteArray")
    'pixels = bigbm.GetByteArray(0,0,bigbm.GetWidth(), bigbm.GetHeight())  

	for y = 0 to bigbm.GetHeight()
	'for x=0 to bigbm.GetWidth()

	apixel=bigbm.GetByteArray(0,y,bigbm.GetWidth(), 1)
	pixels.append(apixel)

	'end for
	end for
    
    'tmp = rdTempFile(".png")
    'print "pixels File "+tmp    
    'pixels.writefile(tmp)
    
    'myurl=CreateObject("roUrlTransfer")
    'myurl.SetUrl("http://192.168.2.2/roku/upload.php")
    'myurl.AddHeader("Content-Type", "image/png")
    'myurl.PostFromFile(tmp)
     
    Print "Encoding PNG now"
    png = CreateObject("roByteArray")
'm.profiler.start("Create PNG")     
    png = toPNG(bigbm.GetWidth(),bigbm.GetHeight(),pixels,false)
'm.profiler.stop("Create PNG")     
    print "PNG Count = "+ png.Count().ToStr()

    tmp = rdTempFile(".png")
    print "File "+tmp    
    png.writefile(tmp)
    print "Displaying PNG"
    
  
    myurl=CreateObject("roUrlTransfer")
    myurl.SetUrl("http://192.168.2.2/roku/upload.php")
    myurl.AddHeader("Content-Type", "image/png")
    myurl.PostFromFile(tmp)
    
    'stop   

    
    newPNG=CreateObject("roBitmap", tmp)
    
    DeleteFile(tmp)
                
    if newPNG = invalid
        print "newPNG create failed"
        stop
    endif    


    'screen.drawobject(0, 0, bigbm)
    'screen.drawobject(bigbm.GetWidth(), bigbm.GetHeight(), newPNG)
    screen.drawobject(0, 0, newPNG)
    screen.SwapBuffers()    

'm.profiler.DumpStats()

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


 