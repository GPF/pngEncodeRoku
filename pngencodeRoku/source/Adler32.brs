
function calcADLER32(araw as object) as integer

	s1% = 1
	s2% = 0
	lastn%=araw.count()-1
	for i% = 0 to lastn%
		'abs = rdIIf((araw[i] >=0),(araw[i]),(not araw[i] ))
		'if araw[i%] >=0 then
			abs%=araw[i%]
		'else
		'	abs%=not araw[i%]
		'end if
		s1% = (s1% + abs%) MOD 65521
		s2% = (s2% + s1%) MOD 65521
	end for
	
	ad%=(s2%*65536) + s1%
	
	return ad%
	
end function


function ADLER32_Combine(adler1 as integer, adler2 as integer, len2 as integer) as integer

	len2=len2 MOD 65521
	remv = len2
	
	sum1 = adler1 AND &HFFFF
	sum2 = remv * sum1
	
	sum2=sum2 MOD 65521
	sum1=sum1 + (adler2 AND &HFFFF) + 65521 - 1
	'sum2=sum2 + ((rdRightShift(adler1,16)) AND &HFFFF) + ((rdRightShift(adler2,16)) AND &HFFFF) + 65521 - remv
	sum2=sum2 + ((adler1/65536) AND &HFFFF) + ((adler2/65536) AND &HFFFF) + 65521 - remv
	if (sum1 >= 65521) sum1 = sum1 - 65521
	if (sum1 >= 65521) sum1 = sum1 - 65521
	if (sum2 >= (65521*2^1)) sum2 = sum2 - (65521*2^1)
	if (sum2 >= 65521) sum2 = sum2 - 65521 
	
	ad= (sum2*65536) + sum1
	
	return ad
	
end function

function calcOneADLER32(araw as integer) as integer

		return (((((1+ araw) MOD 65521)) MOD 65521)*65536)+(1+ araw)

end function

function ADLER32calc() as object
	this = {
		'Member vars
		s1%:1
		s2%:0
		
		'Methods
		ResetAdler: function () as integer
			m.s1%=1
			m.s2%=2
		end function
		UpdateAdler: function (abs% as integer)
			'print "ms1= "+m.s1%.toStr()
			'print "ms2= "+m.s2%.toStr()	
			'print "abs= "+abs%.toStr()
			's1%=m.s1%
			's2%=m.s2%
			m.s1% = (m.s1% + abs%) MOD 65521
			m.s2% = (m.s2% + m.s1%) MOD 65521
			'm.s1%=s1%
			'm.s2%=s2%

		end function
		TotalAdler: function () as integer
			return (m.s2%*65536) + m.s1%
		end function
		}
	return this
end function		