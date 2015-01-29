;transfer radiance image to reflectance
;Yen-Ben Cheng
;october 2014

pro rad2refl, infile, scale, irrad, outfile
;rad2refl, 'C:\Users\Yen-Ben\Documents\IDL\rad2refl\input', 1, [1.19,1.10,0.93,0.86,0.84,0.73],'C:\Users\Yen-Ben\Documents\IDL\rad2refl\output'

;this program is designed to calculate reflectance from images that's already transfered to radiance
;check the wavelength of each of the band and make sure the irrad is in the right order
;
;irradiance values are simulated with SMARTS, in W/m2/nm
;if radiance values are not in W/m2/sr/nm, use the scale variable to correct it
;refltance are calculated as rad/(irrad/pi)
;
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

if (interleave NE 0) then begin           ;input file needs to be in BSQ format
  print, 'input file needs to be in BSQ format'
  return
endif

if (data_type eq 4) then begin            ;input data type is floating point
  print, 'input data type is floating point'
  rad = fltarr (nsamples, nlines, nbands)
  openr, lun, infile, /get_lun
  readu, lun, rad
  close, lun
endif else begin
  if (data_type eq 1) then begin          ;input data type is byte
    print, 'input data type is byte'
    rad = bytarr (nsamples, nlines, nbands)
    openr, lun, infile, /get_lun
    readu, lun, rad
    close, lun
    rad = float(rad)
  endif else begin
    if (data_type eq 12) then begin       ;input data type is unsigned integer
      print, 'input data type is unsigned integer'
      rad = uintarr (nsamples, nlines, nbands)
      openr, lun, infile, /get_lun
      readu, lun, rad
      close, lun
      rad = float(rad)
    endif else begin
      if (data_type eq 2) then begin      ;input data type is integer
        print, 'input data type is integer'
        rad = intarr (nsamples, nlines, nbands)
        openr, lun, infile, /get_lun
        readu, lun, rad
        close, lun
        rad = float(rad)
      endif else begin
        print, 'check input file data type'
      endelse
    endelse
  endelse
endelse

refl = fltarr (nsamples, nlines, nbands)

;apply the scale and calculate reflectance using simulated irradiance
for i = 0, nsamples-1 do begin
  for j = 0, nlines-1 do begin
    for k = 0, nbands-1 do begin
      refl(i,j,k) = (rad(i,j,k)*scale) / (irrad(k) / !pi)
    endfor
  endfor
  print, float(i)/float(nsamples)
endfor

openw, lun, outfile
writeu, lun, refl
close, lun

end