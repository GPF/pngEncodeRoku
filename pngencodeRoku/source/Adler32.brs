
function calcADLER32(araw as object) as integer

	s1 = 1
	s2 = 0
	for i = 0 to araw.count()-1
		abs = rdIIf((araw[i] >=0),(araw[i]),(not araw[i] ))
		s1 = (s1 + abs) MOD 65521
		s2 = (s2 + s1) MOD 65521
	end for
	
	ad=(s2*2^16) + s1
	
	return ad
	
end function


function ADLER32_Combine(adler1 as integer, adler2 as integer, len2 as integer) as integer

	len2=len2 MOD 65521
	remv = len2
	
	sum1 = adler1 AND &HFFFF
	sum2 = remv * sum1
	
	sum2=sum2 MOD 65521
	sum1=sum1 + (adler2 AND &HFFFF) + 65521 - 1
	sum2=sum2 + ((rdRightShift(adler1,16)) AND &HFFFF) + ((rdRightShift(adler2,16)) AND &HFFFF) + 65521 - remv
	
	if (sum1 >= 65521) sum1 = sum1 - 65521
	if (sum1 >= 65521) sum1 = sum1 - 65521
	if (sum2 >= (65521*2^1)) sum2 = sum2 - (65521*2^1)
	if (sum2 >= 65521) sum2 = sum2 - 65521 
	
	ad= (sum2*2^16) + sum1
	
	return ad
	
end function
