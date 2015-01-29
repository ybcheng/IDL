;transfer raw image DN to radiance 
;Yen-Ben Cheng
;October 2014

pro raw2rad, infile, scale, intTime, gain, offset, outfile
;raw2rad, 'C:\Users\Yen-Ben\Documents\IDL\raw2rad\input', 4.0, [1.0,1.0,1.5,1.5,1.0,1.9], [0.00022461,0.00031737,0.00026080,0.00026177,0.00027219,0.00031736], [0.0,0.0,0.0,0.0,0.0,0.0],'C:\Users\Yen-Ben\Documents\IDL\raw2rad\output'

;this program is designed to apply gain and offset coefficients to transfer raw DN to radiance readings
;check the wavelength of each of the bands and make sure all the coefficients are in the right order
;
;the gain and offset coefficients, both are floating point array, were developed using data in 10-bit format
;therefore, apply the scale to the data and make it in 10-bit format
;for example, the scale for 8-bit data is 4.0; for 16-bit data is 1.0/64.0
;
;intTime is integration time (ms), a floating point array, make sure the numbers are in the correct order
;rad = ((DN*scale)/intTime)*gain + offset
;input file needs to be in BSQ format

e=ENVI(/headless)

;open and read the input image file
envi_open_file, infile, r_fid=fid
if (fid eq -1) then return

envi_file_query, fid, ns=nsamples, nl=nlines, nb=nbands, interleave=interleave, data_type=data_type
envi_file_mng, id=fid, /remove

if (nbands NE 6) then begin               ;input file needs to have exactly six bands
  envi_report_error, 'Incorrect number of bands!', /cancel
  return
endif

if (interleave NE 0) then begin        ;input file needs to be in BSQ format
  ;print, 'input file needs to be in BSQ format'
  envi_report_error, 'Incorrect interleave type! Please convert the source image to BSQ format.', /cancel
  return
endif

if (data_type eq 4) then begin        ;input data type is floating point
  print, 'input data type is floating point'
  raw = fltarr (nsamples, nlines, nbands)
  openr, lun, infile, /get_lun
  readu, lun, raw
  close, lun
endif else begin
  if (data_type eq 1) then begin      ;input data type is byte
    print, 'input data type is byte'
    raw = bytarr (nsamples, nlines, nbands)
    openr, lun, infile, /get_lun
    readu, lun, raw
    close, lun
    raw = float(raw)
  endif else begin
    if (data_type eq 12) then begin   ;input data type is unsigned integer
      print, 'input data type is unsigned integer'
      raw = uintarr (nsamples, nlines, nbands)
      openr, lun, infile, /get_lun
      readu, lun, raw
      close, lun
      raw = float(raw)
    endif else begin
      if (data_type eq 2) then begin   ;input data type is integer
        print, 'input data type is integer'
        raw = intarr (nsamples, nlines, nbands)
        openr, lun, infile, /get_lun
        readu, lun, raw
        close, lun
        raw = float(raw)
      endif else begin
        print, 'check input file data type'
      endelse
    endelse
  endelse
endelse

rad = fltarr (nsamples, nlines, nbands)

;apply the gain and offset to DN
for i = 0, nsamples-1 do begin
  for j = 0, nlines-1 do begin
    for k = 0, nbands-1 do begin
      rad(i,j,k) = (raw(i,j,k)*scale/intTime(k))*gain(k) + offset(k)
    endfor
  endfor
  print, float(i)/float(nsamples)
endfor

openw, lun, outfile
writeu, lun, rad
close, lun

end