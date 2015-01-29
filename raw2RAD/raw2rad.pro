;transfer raw image DN to radiance 
;Yen-Ben Cheng
;October 2014

pro raw2rad, infile, scale, intTime, gain, offset, outfile
;raw2rad, 'C:\Users\Yen-Ben\Documents\IDL\raw2rad\input.img', 4.0, [1.0,1.0,1.5,1.5,1.0,1.9], [0.00022461,0.00031737,0.00026080,0.00026177,0.00027219,0.00031736], [0.0,0.0,0.0,0.0,0.0,0.0],'C:\Users\Yen-Ben\Documents\IDL\raw2rad\output.img'

;this program is designed to apply gain and offset coefficients to transfer raw DN to radiance readings
;check the wavelength of each of the bands and make sure all the coefficients are in the right order
;
;the gain and offset coefficients, both are floating point array, were developed using data in 10-bit format
;therefore, apply the scale to the data and make it in 10-bit format
;for example, the scale for 8-bit data is 4.0; for 16-bit data is 1.0/64.0
;
;intTime is integration time (ms), a floating point array, make sure the numbers are in the correct order
;rad = ((DN*scale)/intTime)*gain + offset


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

CASE interleave OF
  0: BEGIN  
    PRINT, 'input file is in BSQ format:',nsamples,',',nlines,',',nbands
    CASE data_type OF
      1: raw = BYTARR  (nsamples, nlines, nbands) ;input data type is byte
      2: raw = INTARR  (nsamples, nlines, nbands) ;input data type is integer
      4: raw = FLTARR  (nsamples, nlines, nbands) ;input data type is floating point
      12: raw = UINTARR(nsamples, nlines, nbands) ;input data type is unsigned integer
      ELSE: BEGIN
        ENVI_REPORT_ERROR, 'check input file data type', /cancel
        RETURN
      END
    ENDCASE
    openr, lun, infile, /get_lun
    readu, lun, raw
    close, lun
    raw = FLOAT(raw)
  END
  1: BEGIN  
    PRINT, 'input file is in BIL format:',nsamples,',',nbands,',',nlines
    CASE data_type OF
      1: raw = BYTARR  (nsamples, nbands, nlines) ;input data type is byte
      2: raw = INTARR  (nsamples, nbands, nlines) ;input data type is integer
      4: raw = FLTARR  (nsamples, nbands, nlines) ;input data type is floating point
      12: raw = UINTARR(nsamples, nbands, nlines) ;input data type is unsigned integer
      ELSE: BEGIN
        ENVI_REPORT_ERROR, 'check input file data type', /cancel
        RETURN
      END
    ENDCASE
    openr, lun, infile, /get_lun
    readu, lun, raw
    close, lun
    raw = FLOAT(raw)
    raw = TRANSPOSE(raw, [0,2,1])
  END
  2: BEGIN  
    PRINT, 'input file is in BIP format:',nbands,',',nsamples,',',nlines
    CASE data_type OF
      1: raw = bytarr  (nbands, nsamples, nlines) ;input data type is byte
      2: raw = intarr  (nbands, nsamples, nlines) ;input data type is integer
      4: raw = fltarr  (nbands, nsamples, nlines) ;input data type is floating point
      12: raw = uintarr(nbands, nsamples, nlines) ;input data type is unsigned integer
      ELSE: BEGIN
        ENVI_REPORT_ERROR, 'check input file data type', /cancel
        RETURN
      END
    ENDCASE
    OPENR, lun, infile, /get_lun
    READU, lun, raw
    CLOSE, lun
    raw = FLOAT(raw)
    raw = TRANSPOSE(raw, [1,2,0])
  END
ENDCASE

rad = FLTARR (nsamples, nlines, nbands)

;apply the gain and offset to DN
for i = 0, nsamples-1 do begin
  for j = 0, nlines-1 do begin
    for k = 0, nbands-1 do begin
      rad(i,j,k) = (raw(i,j,k)*scale/intTime(k))*gain(k) + offset(k)
    endfor
  endfor
  PRINT, FLOAT(i)/FLOAT(nsamples)
endfor

OPENW, lun, outfile
WRITEU, lun, rad
CLOSE, lun

end