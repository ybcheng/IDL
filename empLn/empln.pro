;empirical line correction
;Yen-Ben Cheng
;October 2014

pro empLn, infile, fieldB, fieldD, imgB, imgD, outfile
;empLn,'C:\Users\Yen-Ben\Documents\IDL\empLn\input.img',[0.4821,0.4891,0.4736,0.4719,0.4752,0.4713],[0.0712,0.0761,0.0643,0.0629,0.0654,0.0620],[204,145,203,223,151,206],[53,34,59,91,41,82],'C:\Users\Yen-Ben\Documents\IDL\empLn\output.img'

;this program is designed to manually apply empirical line atmospheric correction to
;derive reflectance from raw or radiance values from airborne imagery
;instead of using the default process in ENVI
;check the wavelength of each of the bands and make sure all the coefficients are in the right order
;
;the fieldB and fieldD array are the bright and dark targets measured in the field (e.g. using ASD)
;the imgB and imgD array are the bright and dark targets measured by the aerial RS system (i.e. from the imagery)
;
;input file needs to be in BSQ format
;
e=ENVI(/headless)

;open and read the input image file
envi_open_file, infile, r_fid=fid
if (fid eq -1) then return

envi_file_query, fid, ns=nsamples, nl=nlines, nb=nbands, interleave=interleave, data_type=data_type
envi_file_mng, id=fid, /remove

if (nbands NE 6) then begin               ;input file needs to have exactly six bands
  print, 'check number of bands'
  return
endif

if (interleave NE 0) then begin        ;input file needs to be in BSQ format
  print, 'input file needs to be in BSQ format'
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

refl = fltarr (nsamples, nlines, nbands)

;calculate the empirical line coefficients band by band and then
;apply the gain and offset to raw imagery
for k = 0, nbands-1 do begin
  X = [imgD[k], imgB[k]]        ;bright and dark target from imgery
  Y = [fieldD[k], fieldB[k]]    ;bright and dark target from field
  results = REGRESS(X, Y, CONST=const)
  for i = 0, nsamples-1 do begin
    for j = 0, nlines-1 do begin
      refl(i,j,k) = (raw(i,j,k)*results[0]) + const
    endfor
  endfor
  print, k
endfor

openw, lun, outfile
writeu, lun, refl
close, lun

end