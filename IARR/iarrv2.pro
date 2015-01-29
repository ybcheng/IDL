pro IARRv2, infile, intrlv, nbands, nlines, nsamples, outfile

;atmospheric correction using the internal average relative reflectance (IARR) method
  
;intrlv: 1=BSQ, 2=BIP, 3=BIL
  
if (intlv EQ 1) THEN Begin
  ;open and read the input image file
  ;NOTE: this file's in BSQ format
  rfl = intarr (nsamples, nlines, nbands)
  openr, lun, infile, /get_lun
  readu, lun, rfl
  close, lun
  
  ;calculate the IARR output
  out_rfl = fltarr(nsamples, nlines, nbands)
  
  for i = 0, nbands-1 do begin
    for j = 0, nsamples-1 do begin
      for k = 0, nlines-1 do begin
        out_rfl(j,k,i) = rfl(j,k,i)/mean(rfl(0:nsamples-1, nlines-1, k))
      endfor
    endfor
  endfor
endif

if (intlv EQ 2) THEN Begin
  ;open and read the input image file
  ;NOTE: this file's in BIP format
  rfl = intarr (nbands, nsamples, nlines)
  openr, lun, infile, /get_lun
  readu, lun, rfl
  close, lun
  
  ;calculate the IARR output
  out_rfl = fltarr(nbands, nsamples, nlines)
  
  for i = 0, nbands-1 do begin
    for j = 0, nsamples-1 do begin
      for k = 0, nlines-1 do begin
        out_rfl(i,j,k) = rfl(i,j,k)/mean(rfl(i,0:nsamples-1, nlines-1))
      endfor
    endfor
  endfor
endif

if (intlv EQ 3) THEN Begin
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
endif
  
  
openw, lun, outfile
writeu, lun, out_rfl
close, lun
  
end