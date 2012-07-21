function toZLIB(zraw as object) as object

BLOCK_SIZE = 32000

	zlib = CreateObject("roByteArray")
	
	'zlib.setresize(zraw.count() + 6 + (zraw.count() / BLOCK_SIZE) * 5, false)

	zlib.push(8)					' CM = 8, CMINFO = 0
	zlib.push((31 - ((8*2^8) MOD 31)) MOD 31)	  ' FCHECK (FDICT/FLEVEL=0)
	
	posit = 0

	while ( (zraw.count() - posit) > BLOCK_SIZE )

		zlib.append(writeUncompressedDeflateBlock(0, zraw, posit, BLOCK_SIZE) )

      		posit = posit + BLOCK_SIZE
	end while


	zlib.append(writeUncompressedDeflateBlock(1, zraw, posit, (zraw.count() - posit)) )
	
	print "zlib.count = "+zlib.count().toStr()
	'ad= calcADLER32(zraw)
	'n=ADLER32calc()
	'for i = 0 to zraw.count()-1
	'	n.UpdateAdler(zraw[i])
	'endfor
	'zlib.append(rdINTtoBA(ad))
	'ad=n.TotalAdler()
	
	'print "ad= "+ad.ToStr()
	
	ad= calcADLER32(zraw)
	
	'print "ad= "+ad.ToStr()
	zlib.append(rdINTtoBA(ad))
	print "zlib.count +ADLER32= "+zlib.count().toStr()
	return zlib
end function

function writeUncompressedDeflateBlock(lastcompress as integer, uraw as object, offs as integer, lengths as integer) as object

	uzlib = CreateObject("roByteArray")


	uzlib.push(lastcompress) 			' Final flag, Compression type 
				
	uzlib.push(lengths and &HFF)			' Length LSB 

	uzlib.push( (lengths and &HFF00)/256 )		' Length MSB

	uzlib.push( (NOT lengths) and &HFF)		' Length 1st complement LSB

	uzlib.push(((NOT lengths) and &HFF00)/256)	' Length 1st complement MSB

	
'	sraw=uraw.toHexString()
'	strraw=sraw.Mid(offs*2, (lengths)*2)
'	uzlib.FromHexString(strraw)
	
	uzlib.append(rdBAcopy(uraw,offs,offs+lengths))	' Data 
		

	return uzlib
	
end function