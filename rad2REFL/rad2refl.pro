;transfer radiance image to reflectance
;Yen-Ben Cheng
;october 2014

pro rad2refl, infile, scale, irrad, outfile
;rad2refl, 'C:\Users\Yen-Ben\Documents\IDL\rad2refl\input.img', 1, [1.19,1.10,0.93,0.86,0.84,0.73],'C:\Users\Yen-Ben\Documents\IDL\rad2refl\output.img'

;this program is designed to calculate reflectance from images that's already transfered to radiance
;check the wavelength of each of the band and make sure the irrad is in the right order
;
;irradiance values are simulated with SMARTS, in W/m2/nm
;if radiance values are not in W/m2/sr/nm, use the scale variable to correct it
;refltance are calculated as rad/(irrad/pi)

  
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
      1: rad = BYTARR  (nsamples, nlines, nbands) ;input data type is byte
      2: rad = INTARR  (nsamples, nlines, nbands) ;input data type is integer
      4: rad = FLTARR  (nsamples, nlines, nbands) ;input data type is floating point
      12: rad = UINTARR(nsamples, nlines, nbands) ;input data type is unsigned integer
      ELSE: BEGIN
        ENVI_REPORT_ERROR, 'check input file data type', /cancel
        RETURN
      END
    ENDCASE
    openr, lun, infile, /get_lun
    readu, lun, rad
    close, lun
    rad = FLOAT(rad)
  END
  1: BEGIN
    PRINT, 'input file is in BIL format:',nsamples,',',nbands,',',nlines
    CASE data_type OF
      1: rad = BYTARR  (nsamples, nbands, nlines) ;input data type is byte
      2: rad = INTARR  (nsamples, nbands, nlines) ;input data type is integer
      4: rad = FLTARR  (nsamples, nbands, nlines) ;input data type is floating point
      12: rad = UINTARR(nsamples, nbands, nlines) ;input data type is unsigned integer
      ELSE: BEGIN
        ENVI_REPORT_ERROR, 'check input file data type', /cancel
        RETURN
      END
    ENDCASE
    OPENR, lun, infile, /get_lun
    READU, lun, rad
    CLOSE, lun
    rad = FLOAT(rad)
    rad = TRANSPOSE(rad, [0,2,1])
  END
  2: BEGIN
    PRINT, 'input file is in BIP format:',nbands,',',nsamples,',',nlines
    CASE data_type OF
      1: rad = BYTARR  (nbands, nsamples, nlines) ;input data type is byte
      2: rad = INTARR  (nbands, nsamples, nlines) ;input data type is integer
      4: rad = FLTARR  (nbands, nsamples, nlines) ;input data type is floating point
      12: rad = UINTARR(nbands, nsamples, nlines) ;input data type is unsigned integer
      ELSE: BEGIN
        ENVI_REPORT_ERROR, 'check input file data type', /cancel
        RETURN
      END
    ENDCASE
    OPENR, lun, infile, /get_lun
    READU, lun, rad
    CLOSE, lun
    rad = FLOAT(rad)
    rad = TRANSPOSE(rad, [1,2,0])
  END
ENDCASE

refl = fltarr (nsamples, nlines, nbands)

;apply the scale and calculate reflectance using simulated irradiance
FOR i = 0, nsamples-1 DO BEGIN
  FOR j = 0, nlines-1 DO BEGIN
    FOR k = 0, nbands-1 DO BEGIN
      refl(i,j,k) = (rad(i,j,k)*scale) / (irrad(k) / !pi)
    ENDFOR
  ENDFOR
  PRINT, FLOAT(i)/FLOAT(nsamples)
ENDFOR

OPENW, lun, outfile
WRITEU, lun, refl
CLOSE, lun

end