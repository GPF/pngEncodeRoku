function toZLIB(zraw as object,finaldata as boolean) as object

BLOCK_SIZE = 32000

	zlib = CreateObject("roByteArray")
	azlib = CreateObject("roByteArray")
	czlib = CreateObject("roByteArray")	
	'zlib.setresize(zraw.count() + 6 + (zraw.count() / BLOCK_SIZE) * 5, false)
'if (not finaldata) then
	zlib.push(8)					' CM = 8, CMINFO = 0
	zlib.push((31 - ((8*2^8) MOD 31)) MOD 31)	  ' FCHECK (FDICT/FLEVEL=0)
'end if	
	posit = 0
	'print "zraw.count = "+zraw.count().toStr()
	while ( (zraw.count() - posit) > BLOCK_SIZE )

		azlib=writeUncompressedDeflateBlock(false, zraw, posit, BLOCK_SIZE)
		'stop
		zlib.append(azlib)
      		posit = posit + BLOCK_SIZE
	end while
	'stop

	czlib=writeUncompressedDeflateBlock(finaldata, zraw, posit, (zraw.count() - posit))
	zlib.append(czlib)
	
	'stop
'if (not finaldata) then	
	ad= calcADLER32(zraw)
	'stop
	dzlib = CreateObject("roByteArray")
	dzlib = rdINTtoBA(ad)
	zlib.append(dzlib)
'end if
	return zlib
end function

function writeUncompressedDeflateBlock(lastcompress as boolean, uraw as object, offs as integer, lengths as integer) as object

	bzlib = CreateObject("roByteArray")
	uzlib = CreateObject("roByteArray")
	lst=rdIIf(lastcompress,1,0) 
	uzlib.push(lst)			' Final flag, Compression type 
	lsb= lengths and &HFF
	uzlib.push( lsb)				' Length LSB 
	msb=rdRightShift( (lengths and &HFF00),8)
	'stop
	uzlib.push(msb )	' Length MSB
	nlsb=((NOT lengths) and &HFF) 
	uzlib.push( nlsb)			' Length 1st complement LSB
	nmsb =rdRightShift( ( (NOT lengths) and &HFF00),8)
	'stop
	uzlib.push( nmsb)' Length 1st complement MSB
	bzlib = rdBAcopy(uraw,offs,offs+lengths)
	uzlib.append(bzlib)		' Data 
	'stop
	return uzlib
	
end function