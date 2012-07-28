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

function toPNG(width as integer, height as integer,pixels as object, indexed as boolean) as object

	signature = CreateObject("roByteArray")
	signature.push(137)	'non-ascii
	signature.push(80)	'P
	signature.push(78)	'N
	signature.push(71)	'G
	signature.push(13)	'\r
	signature.push(10)	'\n
	signature.push(26)	'control-Z
	signature.push(10)	'\n
	
	headers= CreateObject("roByteArray")
	headers = createHeaderChunk(width, height,indexed)

	if (indexed) then
	pltindexeddata = CreateObject("roByteArray")
	pltindexeddata = createPLTEDataChunk(width, height, pixels)	
	else

	data = CreateObject("roByteArray")
	data = createDataChunk(width, height, pixels)
	'data = IDATChunk(width,height, pixels)
	end if

	trailer = CreateObject("roByteArray")	
	trailer = createTrailerChunk()
	
	png = CreateObject("roByteArray")
	png.append(signature)
	png.append(headers)
	if (indexed) then
		png.append(pltindexeddata)
	else
		png.append(data)
	endif		
	png.append(trailer)

	return png
end function
  
function createHeaderChunk(width as integer, height as integer, colortype as boolean) as object

	achunk = CreateObject("roByteArray")
	chunk = CreateObject("roByteArray")
	chunk.setresize(13, false)

	achunk = ( rdINTtoBA(width) )
	chunk.append(achunk)

	achunk = ( rdINTtoBA(height) )
	chunk.append(achunk)

	chunk.push(8) ' Bitdepth
	if colortype then
		chunk.push(3) ' Colortype paletted RGB 
	else
		chunk.push(6) ' Colortype RGBA 
	endif
	chunk.push(0) ' Compression
	chunk.push(0) ' Filter
	chunk.push(0) ' Interlace  	

	return toChunk("IHDR",chunk)
end function

function createPaletteChunk(palette as object) as object

	return toChunk("PLTE",palette)
end function

function createPLTEDataChunk(width as integer, height as integer, pixels as object) as object
	
	
	
	raw = CreateObject("roByteArray")
	pltraw = CreateObject("roByteArray")
	dtraw  = CreateObject("roByteArray")

	colorhash = CreateObject("roAssociativeArray")
	hxstr="000000"
	colorhash.AddReplace(hxstr, 0) ' TRANSPARENT_DATA
	raw.FromHexString(hxstr)
	pltraw.append(raw)
	lastcolor=hxstr
	lastindex=0
	hxstr=pixels.toHexString()
	
	'tixels  = CreateObject("roByteArray")
	indexp=1
	y=0
	
	dtraw.push(0 ) ' No filter
	for x = 0 to hxstr.len() step 8
	

		
		keyp=hxstr.mid(x,6)
		
		if (keyp=lastcolor) then
			dtraw.push(lastindex)
			y=y+1
			'tixels.push(lastindex)
			'print "FOUND - "+keyp
			goto nextit
		endif
		
		if colorhash.DoesExist(keyp) then
			inx=colorhash.lookup( keyp )
			dtraw.push(inx)
			'tixels.push(inx)
			y=y+1
			lastcolor=keyp
			lastindex=inx
		else
			colorhash.AddReplace(keyp, indexp)
			raw.FromHexString( keyp )
			pltraw.append(raw)
			dtraw.push(indexp )
			'tixels.push(indexp)
			lastcolor=keyp
			lastindex=indexp			
			indexp=indexp+1
			y=y+1
		endif
nextit:		

		if(y MOD width) =0 then
			dtraw.push(0 ) ' No filter

		endif
	

	endfor	
	
    'tmp = rdTempFile(".png")
    'print "pixels File "+tmp    
    'pltraw.writefile(tmp)
    
    'myurl=CreateObject("roUrlTransfer")
    'myurl.SetUrl("http://192.168.2.2/roku/upload.php")
    'myurl.AddHeader("Content-Type", "image/png")
    'myurl.PostFromFile(tmp)
	
    'tmp = rdTempFile(".png")
    'print "pixels File "+tmp    
    'dtraw.writefile(tmp)
    
    'myurl=CreateObject("roUrlTransfer")
    'myurl.SetUrl("http://192.168.2.2/roku/upload.php")
    'myurl.AddHeader("Content-Type", "image/png")
    'myurl.PostFromFile(tmp)
    
	print "draw.count = "+dtraw.count().toStr()

	craw = CreateObject("roByteArray")	
	craw= createPaletteChunk(pltraw)
	craw.append(toChunk("IDAT", toZLIB(dtraw)))
	'craw.append(IDATChunk(width,height, dtraw))
	'raw.append(createDataChunk(width, height, pixels))
	return craw	
end function

function createDataChunk(width as integer, height as integer, pixels as object) as object
	
	source = 0
	dest = 0
	  
	raw = CreateObject("roByteArray")
'	'raw.setresize(4*(width*(eheight-sheight)) + (eheight-sheight), false)
'	'print "4*sheight*width = "+(4*sheight*width).toStr()
'	for y = sheight to eheight-1
'		raw[dest] = 0 ' No filter
'		dest=dest+1
'		
'		for x = 0 to width-1
'		
'		raw[dest] = pixels[source+(4*sheight*width)] 'red
'		dest=dest+1
'		source=source+1
'		raw[dest] = pixels[source+(4*sheight*width)] 'green
'		dest=dest+1
'		source=source+1		
'		raw[dest] = pixels[source+(4*sheight*width)] 'blue
'		dest=dest+1
'		source=source+1	
'		raw[dest] = pixels[source+(4*sheight*width)] 'alpha
'		dest=dest+1
'		source=source+1			
'		
'		end for	
'	end for	

'    hxstr=pixels.toHexString()
'    regfind="(.{"+(width*8).toStr()+"})"
'    r = CreateObject("roRegex",regfind , "")
'    hxstr=r.ReplaceAll(hxstr, "\100")
'
'    hxstr="00"+hxstr.left(hxstr.len()-2)
'
'    raw.FromHexString(hxstr)
	print "pixels.count = "+pixels.count().toStr()
	for y = 0 to height-1
		raw.push(0) ' No filter
		raw.append( rdBAcopy(pixels,(y*width*4),(y*width*4)+(width*4) ) )
	end for
	
	print "raw.count = "+raw.count().toStr()
	return toChunk("IDAT", toZLIB(raw))	
end function


function createTrailerChunk() as object
	return toChunk("IEND",CreateObject("roByteArray"))
end function


function toChunk(id as string, traw as object) as object

	chunk = CreateObject("roByteArray")
	'chunk.setresize(traw.count() + 12,false)
	achunk = CreateObject("roByteArray")
	achunk = (rdINTtoBA(traw.count())) ' width*height*4+height for filter +16zlibheader

	chunk.append(achunk)
	
	bnid = CreateObject("roByteArray")
	bnid.setresize(4,false)

	for i = 1 to 4

		bnid.push(asc(mid(id,i,1)))
		
	end for
	
	chunk.append(bnid)
	chunk.append(traw)
	
	'c=rdCRC()
	c=slice8CRC()
	
	crc = &HFFFFFFFF
	crc = c.updateSlice8CRC(crc,bnid)
	crc = c.updateSlice8CRC(crc,traw)
	
	achunk = (rdINTtoBA(not crc))	
	chunk.append(achunk)
	print "crc.count = "+achunk.count().toStr()
	return chunk
	
end function 

function IDATChunk(width% as integer,height% as integer,pixels as object) as object

	chunk = CreateObject("roByteArray")
	chunk.setresize(pixels.count() + height% + 100,true)
	chunk.push(0)'placeholder for idat size
	chunk.push(0)'placeholder for idat size
	chunk.push(0)'placeholder for idat size
	chunk.push(0)'placeholder for idat size
	
	n=ADLER32calc()
	c=rdCRC()
	'c.populateTable()
	
	y%=0
	x%=0
	f%=0
	BLOCK_SIZE% = 65535
	zlength%=BLOCK_SIZE%
	
	id%=asc("I"):chunk.push(id%):c.updateOneCRC(id%)
	id%=asc("D"):chunk.push(id%):c.updateOneCRC(id%)
	id%=asc("A"):chunk.push(id%):c.updateOneCRC(id%)
	id%=asc("T"):chunk.push(id%):c.updateOneCRC(id%)

	'Zlib Header
	chunk.push(8):c.updateOneCRC(8)						' CM = 8, CMINFO = 0
	chunk.push(29):c.updateOneCRC(29):f%=f%+2				' FCHECK (FDICT/FLEVEL=0)

	for i% = 0 to pixels.count()-1
	
		if ((y%+x%) MOD (BLOCK_SIZE%)) =0 then 

			if (( pixels.count()-y%) < BLOCK_SIZE%) then
				zlength%=(pixels.count()-y%)'+(height%-x%)
				chunk.push(1):c.updateOneCRC(1)						' Final flag, Compression type
				print "y= "+y%.toStr()

				print "zlength= "+zlength%.toStr()
				id%=(zlength% and &HFF):chunk.push(id%):c.updateOneCRC(id%)		' Length LSB 

				id%=((zlength% and &HFF00)/256):chunk.push(id%):c.updateOneCRC(id%)	' Length MSB

				id%=( (NOT zlength%) and &HFF):chunk.push(id%):c.updateOneCRC(id%)	' Length 1st complement LSB

				id%=( ( (NOT zlength%) and &HFF00)/256) 				' Length 1st complement MSB	
				chunk.push(id%):c.updateOneCRC(id%):f%=f%+5

			else
				
				chunk.push(0):c.updateOneCRC(0)						' Final flag, Compression type 
				print "lasty= "+y%.toStr()
				print "zlength= "+zlength%.toStr()
				chunk.push(255):c.updateOneCRC(255)					' Length LSB 

				chunk.push(255):c.updateOneCRC(255)					' Length MSB

				chunk.push(0):c.updateOneCRC(0)						' Length 1st complement LSB

				chunk.push(0):c.updateOneCRC(0):f%=f%+5					' Length 1st complement MSB	
				
			endif
		endif
		
		'if(y% MOD (width%*4)) =0 then
		'	chunk.push(0):c.updateOneCRC(0):n.UpdateAdler(0):f%=f%+1		'no Filter
		'	x%=x%+1
		'endif
		
		id%=pixels.GetSignedByte(i%):chunk.push(id%):
		c.updateOneCRC(id%):n.UpdateAdler(id%):f%=f%+1
		y%=y%+1
	endfor

	
	ad%=n.TotalAdler()
	temp = CreateObject("roByteArray")
	temp = rdINTtoBA(ad%)
	id%=temp.GetSignedByte(0):chunk.push(id%):c.updateOneCRC(id%):f%=f%+1
	id%=temp.GetSignedByte(1):chunk.push(id%):c.updateOneCRC(id%):f%=f%+1
	id%=temp.GetSignedByte(2):chunk.push(id%):c.updateOneCRC(id%):f%=f%+1
	id%=temp.GetSignedByte(3):chunk.push(id%):c.updateOneCRC(id%):f%=f%+1

	datsize=rdINTtoBA(f%) 'idat size
	chunk[0]=datsize[0]
	chunk[1]=datsize[1]
	chunk[2]=datsize[2]
	chunk[3]=datsize[3]
	
	chunk.append(rdINTtoBA(not (c.TotalOneCRC() ) ))
	
	return chunk
end function