' Roku PNG encoder ported by Troy Davis(GPF)
' Takes RGBA ByteArray and encodes it as a png ByteArray

' Minimal PNG encoder to create PNG streams (and MIDP images) from RGBA arrays.
' 
' Copyright 2006-2009 Christian Fröschlin
'
' www.chrfr.de
'
'
' Changelog:
'
' 09/22/08: Fixed Adler checksum calculation and byte order
'           for storing length of zlib deflate block. Thanks
'           to Miloslav Ruzicka for noting this.
'
' 05/12/09: Split PNG and ZLIB functionality into separate classes.
'           Added support for images > 64K by splitting the data into
'           multiple uncompressed deflate blocks.
' 
 
' Terms of Use:  
'
' You may use the PNG encoder free of charge for any purpose you desire, as long
' as you do not claim credit for the original sources and agree not to hold me
' responsible for any damage arising out of its use.
'
' If you have a suitable location in GUI or documentation for giving credit,
' I'd appreciate a mention of
' 
'  PNG encoder (C) 2006-2009 by Christian Fröschlin, www.chrfr.de
'
' but that's not mandatory.
'

function toPNG(width as integer, height as integer,pixels as object) as object

	signature = CreateObject("roByteArray")
	signature.push(137)
	signature.push(80)
	signature.push(78)
	signature.push(71)
	signature.push(13)
	signature.push(10)
	signature.push(26)
	signature.push(10)
	headers= CreateObject("roByteArray")
	headers = createHeaderChunk(width, height)
	startheight=0
	endheight=height'/2
	data = CreateObject("roByteArray")
	data = createDataChunk(width, startheight,endheight, pixels,true)',false)
	
	'startheight=(height/2)
	'endheight=height
	'data2 = CreateObject("roByteArray")
	'data2 = createDataChunk(width, startheight,endheight, pixels,true)
	
	trailer = CreateObject("roByteArray")	
	trailer = createTrailerChunk()
	
	png = CreateObject("roByteArray")
	'png.setresize(signature.count() + headers.count() + data.count() + trailer.count(), false)
	png.append(signature)
	png.append(headers)
	png.append(data)
	'png.append(data2)	
	png.append(trailer)

	return png
end function
  
function createHeaderChunk(width as integer, height as integer) as object

	achunk = CreateObject("roByteArray")
	chunk = CreateObject("roByteArray")
	chunk.setresize(13, false)

	achunk = ( rdINTtoBA(width) )
	chunk.append(achunk)

	achunk = ( rdINTtoBA(height) )
	chunk.append(achunk)

	chunk.push(8) ' Bitdepth
	chunk.push(6) ' Colortype RGBA 
	chunk.push(0) ' Compression
	chunk.push(0) ' Filter
	chunk.push(0) ' Interlace  	

	return toChunk("IHDR",chunk)
end function

  
function createDataChunk(width as integer, sheight as integer,eheight as integer, pixels as object,finaldata as boolean) as object
	
	source = 0
	dest = 0
	  
	raw = CreateObject("roByteArray")
	'raw.setresize(4*(width*(eheight-sheight)) + (eheight-sheight), false)
	'print "4*sheight*width = "+(4*sheight*width).toStr()
	for y = sheight to eheight-1
		raw[dest] = 0 ' No filter
		dest=dest+1
		
		for x = 0 to width-1
		
		raw[dest] = pixels[source+(4*sheight*width)] 'red
		dest=dest+1
		source=source+1
		raw[dest] = pixels[source+(4*sheight*width)] 'green
		dest=dest+1
		source=source+1		
		raw[dest] = pixels[source+(4*sheight*width)] 'blue
		dest=dest+1
		source=source+1	
		raw[dest] = pixels[source+(4*sheight*width)] 'alpha
		dest=dest+1
		source=source+1			
		
		end for	
	end for	
	print "raw.count = "+raw.count().toStr()
	return toChunk("IDAT", toZLIB(raw,finaldata))	
end function


function createTrailerChunk() as object
	return toChunk("IEND",CreateObject("roByteArray"))
end function


function toChunk(id as string, traw as object) as object

	chunk = CreateObject("roByteArray")
	'chunk.setresize(traw.count() + 12,false)
	achunk = CreateObject("roByteArray")
	achunk = (rdINTtoBA(traw.count()))

	chunk.append(achunk)
	
	bnid = CreateObject("roByteArray")
	bnid.setresize(4,false)

	for i = 1 to 4

		bnid.push(asc(mid(id,i,1)))
		
	end for
	
	chunk.append(bnid)
	chunk.append(traw)
	
	crc = &HFFFFFFFF
	crc = rdCRC().updateCRC(crc,bnid)
	crc = rdCRC().updateCRC(crc,traw)
	
	achunk = (rdINTtoBA(not crc))	
	chunk.append(achunk)
	
	return chunk
	
end function 