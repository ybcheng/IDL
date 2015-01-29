pro IARR, infile, nbands, nlines, nsamples, outfile

;atmospheric correction using the internal average relative reflectance (IARR) method

;open and read the input image file
;NOTE: this file's in BIL format
rfl = intarr (nsamples, nbands, nlines)
openr, lun, infile, /get_lun
readu, lun, rfl
close, lun

;calculate the IARR output
out_rfl = fltarr(nsamples, nbands, nlines)

for i = 0, nbands-1 do begin
  for j = 0, nsamples-1 do begin
    for k = 0, nlines-1 do begin
      out_rfl(j,i,k) = rfl(j,i,k)/mean(rfl(0:nsamples-1, i, nlines-1))
    endfor
  endfor
endfor

openw, lun, outfile
writeu, lun, out_rfl
close, lun

end