;Chlorophyll index calculator
;Yen-Ben Cheng
;August 2014

pro ChlIndx, infile, blu, grn, red, redge, fred, nir, outfile

;ChlIndx, 'C:\Users\Yen-Ben\Documents\IDL\VegIndx\input', 1,0,4,2,3,5, 'C:\Users\Yen-Ben\Documents\IDL\VegIndx\output'

;this program is designed to calculate a bunch of indexes for chlorophyll produdct development
;input file needs to be in BSQ format
;band order needs to be provided in the command line

;!!! REMEMBER band number starts at 0 !!!

;blu   = blue          480 nm
;grn   = green         550 nm
;red   = red           670 nm
;redge = red-edge      700 nm
;fred  = far-red       750 nm
;nir   = near infrared 800 nm

e=ENVI(/headless)

;open and read the input image file
envi_open_file, infile, r_fid=fid
if (fid eq -1) then return

envi_file_query, fid, ns=nsamples, nl=nlines, nb=nbands, interleave=interleave, data_type=data_type 
envi_file_mng, id=fid, /remove

if (nbands NE 6) then begin           ;input file needs to have exactly six bands
  envi_report_error, 'Incorrect number of bands!', /cancel
  return
endif

;print, nsamples,'    x',nlines,'    x',nbands

CASE interleave OF
  0: BEGIN  ;input file is in BSQ format
    PRINT, 'input file is in BSQ format:',nsamples,',',nlines,',',nbands
    CASE data_type OF
      1: rfl = BYTARR  (nsamples, nlines, nbands) ;input data type is byte
      2: rfl = INTARR  (nsamples, nlines, nbands) ;input data type is integer
      4: rfl = FLTARR  (nsamples, nlines, nbands) ;input data type is floating point
      12: rfl = UINTARR(nsamples, nlines, nbands) ;input data type is unsigned integer
      ELSE: BEGIN
        ENVI_REPORT_ERROR, 'check input file data type', /cancel
        RETURN
      END
    ENDCASE
    openr, lun, infile, /get_lun
    readu, lun, rfl
    close, lun
    rfl = FLOAT(rfl)
  END
  1: BEGIN  ;input file is in BIL format
    PRINT, 'input file is in BIL format:',nsamples,',',nbands,',',nlines
    CASE data_type OF
      1: rfl = BYTARR  (nsamples, nbands, nlines) ;input data type is byte
      2: rfl = INTARR  (nsamples, nbands, nlines) ;input data type is integer
      4: rfl = FLTARR  (nsamples, nbands, nlines) ;input data type is floating point
      12: rfl = UINTARR(nsamples, nbands, nlines) ;input data type is unsigned integer
      ELSE: BEGIN
        ENVI_REPORT_ERROR, 'check input file data type', /cancel
        RETURN
      END
    ENDCASE
    openr, lun, infile, /get_lun
    readu, lun, rfl
    close, lun
    rfl = FLOAT(rfl)
    rfl = TRANSPOSE(rfl, [0,2,1])
  END
  2: BEGIN  ;input file is in BIP format
    PRINT, 'input file is in BIP format:',nbands,',',nsamples,',',nlines
    CASE data_type OF
      1: rfl = bytarr  (nbands, nsamples, nlines) ;input data type is byte
      2: rfl = intarr  (nbands, nsamples, nlines) ;input data type is integer
      4: rfl = fltarr  (nbands, nsamples, nlines) ;input data type is floating point
      12: rfl = uintarr(nbands, nsamples, nlines) ;input data type is unsigned integer
      ELSE: BEGIN
        ENVI_REPORT_ERROR, 'check input file data type', /cancel
        RETURN
      END
    ENDCASE
    openr, lun, infile, /get_lun
    readu, lun, rfl
    close, lun
    rfl = FLOAT(rfl)
    rfl = TRANSPOSE(rfl, [1,2,0])
  END
ENDCASE

;calculate the indexes
indx = FLTARR(nsamples, nlines, 15)   ;currently calculating 15 indices
  
for i = 0, nsamples-1 do begin
  for j = 0, nlines-1 do begin
    
  ;this part is designed to manipulate bands that have negative reflectance values
  ;DO NOT use it unless neccessary
  ;
  ;if (rfl(i,j,red) LT 0) then begin
  ;  rfl(i,j,red)=0.001
  ;endif
  ;if (rfl(i,j,redge) LT 0) then begin
  ;  rfl(i,j,redge)=0.002
  ;endif
  ;
  ;rfl(i,j,red)=rfl(i,j,red)+0.1
  ;rfl(i,j,redge)=rfl(i,j,redge)+0.1
    
  ;1. NDVI
  indx(i,j,0) = (rfl(i,j,nir)-rfl(i,j,red)) / (rfl(i,j,nir)+rfl(i,j,red))

  ;2. EVI
  indx(i,j,1) = 2.5 * (rfl(i,j,nir)-rfl(i,j,red)) / (rfl(i,j,nir) + 6.0*rfl(i,j,red) - 7.5*rfl(i,j,blu) + 1.0)

  ;3. Green CI
  indx(i,j,2) = (rfl(i,j,nir) / rfl(i,j,grn)) - 1.0

  ;4. Red-edge CI
  indx(i,j,3) = (rfl(i,j,fred) / rfl(i,j,redge)) - 1.0

  ;5. MCARI
  indx(i,j,4) = (rfl(i,j,redge)-rfl(i,j,red) - 0.2*(rfl(i,j,redge) - rfl(i,j,blu))) * (rfl(i,j,redge) / rfl(i,j,red))

  ;6. TCARI
  indx(i,j,5) = 3*((rfl(i,j,redge)-rfl(i,j,red)) - 0.2*(rfl(i,j,redge) - rfl(i,j,blu)) * (rfl(i,j,redge) / rfl(i,j,red)))

  ;7. OSAVI
  indx(i,j,6) = (1.0+0.16) * (rfl(i,j,nir)-rfl(i,j,red)) / (rfl(i,j,nir)+rfl(i,j,red)+0.16)

  ;8. MCARI/OSAVI
  indx(i,j,7) = indx(i,j,4) / indx(i,j,6)

  ;9. TCARI/OSAVI
  indx(i,j,8) = indx(i,j,5) / indx(i,j,6)

  ;10. MTCI
  indx(i,j,9) = (rfl(i,j,fred)-rfl(i,j,redge)) / (rfl(i,j,redge)-rfl(i,j,red))
  
  ;11. MTVI2
  indx(i,j,10) = 1.5*(1.2*(rfl(i,j,nir)-rfl(i,j,grn))-2.5*(rfl(i,j,red)-rfl(i,j,grn))) / $
    sqrt((2.0*rfl(i,j,nir)+1)^2.0 - (6.0*rfl(i,j,nir)) + (5.0*sqrt(rfl(i,j,red))) - 0.5)
    
  ;13. MCARI/MTVI2
  indx(i,j,11) = indx(i,j,4) / indx(i,j,10)
  
  ;13. DCNI   !!! we're using 750 nm instead of 720 nm !!!
  indx(i,j,12) = (rfl(i,j,fred)-rfl(i,j,redge)) / (rfl(i,j,redge) - rfl(i,j,red)) / (rfl(i,j,fred)-rfl(i,j,red)+0.03)

  ;14. MTCI/NDVI
  indx(i,j,13) = indx(i,j,9) / indx(i,j,0)
  
  ;15. GCI/NDVI
  indx(i,j,14) = indx(i,j,2) / indx(i,j,0)
  
  ;16. TVI
  ;indx(i,j,15) = 0.5*(120*(rfl(i,j,fred)-rfl(i,j,grn))-200*(rfl(i,j,red)-rfl(i,j,grn)))
     
  endfor
  print, float(i)/float(nsamples)
endfor
  
openw, lun, outfile
writeu, lun, indx
close, lun
  
end