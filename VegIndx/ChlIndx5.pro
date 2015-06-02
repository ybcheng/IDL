;Chlorophyll index calculator
;Yen-Ben Cheng
;May 2015

pro ChlIndx5, infile, blu, grn, red, redge, nir, outfile

;ChlIndx5, 'C:\Users\Yen-Ben\Documents\IDL\VegIndx\input.img', 1,0,4,2,3, 'C:\Users\Yen-Ben\Documents\IDL\VegIndx\output.img'

;this program is designed to calculate a bunch of indexes for chlorophyll product development
;this is for IDS5 camera system, so it does not have the far-red band@750nm
;band order needs to be provided in the command line

;!!! REMEMBER band number starts at 0 !!!

;blu   = blue          480 nm
;grn   = green         550 nm
;red   = red           670 nm
;redge = red-edge      700 nm
;nir   = near infrared 800 nm

;e=ENVI(/headless)

;open and read the input image file
envi_open_file, infile, r_fid=fid
if (fid eq -1) then return

envi_file_query, fid, ns=nsamples, nl=nlines, nb=nbands, interleave=interleave, data_type=data_type, dims=dims 
;dims=[-1L, 0, nsamples-1, 0, nlines-1]  
;print, nsamples,'    x',nlines,'    x',nbands

if (nbands NE 5) then begin           ;input file needs to have exactly five bands for IDS5 system
  envi_report_error, 'Incorrect number of bands!', /cancel
  return
endif

rfl = FLTARR(nsamples, nlines, nbands)

for i = 0, nbands-1 do begin
  rfl[*,*,i] = envi_get_data(fid=fid, dims=dims, pos=i)
endfor

envi_file_mng, id=fid, /remove

;calculate the indexes
indx = FLTARR(nsamples, nlines, 15)   ;currently calculating 15 indices
  
for i = 0, nsamples-1 do begin
  for j = 0, nlines-1 do begin
      
  ;1. NDVI
  indx(i,j,0) = (rfl(i,j,nir)-rfl(i,j,red)) / (rfl(i,j,nir)+rfl(i,j,red))

  ;2. EVI
  indx(i,j,1) = 2.5 * (rfl(i,j,nir)-rfl(i,j,red)) / (rfl(i,j,nir) + 6.0*rfl(i,j,red) - 7.5*rfl(i,j,blu) + 1.0)

  ;3. Green CI
  indx(i,j,2) = (rfl(i,j,nir) / rfl(i,j,grn)) - 1.0

  ;4. Red-edge CI
  indx(i,j,3) = (rfl(i,j,nir) / rfl(i,j,redge)) - 1.0

  ;5. MCARI
  indx(i,j,4) = (rfl(i,j,redge)-rfl(i,j,red) - 0.2*(rfl(i,j,redge) - rfl(i,j,grn))) * (rfl(i,j,redge) / rfl(i,j,red))

  ;6. TCARI
  indx(i,j,5) = 3*((rfl(i,j,redge)-rfl(i,j,red)) - 0.2*(rfl(i,j,redge) - rfl(i,j,grn)) * (rfl(i,j,redge) / rfl(i,j,red)))

  ;7. OSAVI
  indx(i,j,6) = (1.0+0.16) * (rfl(i,j,nir)-rfl(i,j,red)) / (rfl(i,j,nir)+rfl(i,j,red)+0.16)

  ;8. MCARI/OSAVI
  indx(i,j,7) = indx(i,j,4) / indx(i,j,6)

  ;9. TCARI/OSAVI
  indx(i,j,8) = indx(i,j,5) / indx(i,j,6)

  ;10. MTCI
  indx(i,j,9) = (rfl(i,j,nir)-rfl(i,j,redge)) / (rfl(i,j,redge)-rfl(i,j,red))
  
  ;11. MTVI2
  indx(i,j,10) = 1.5*(1.2*(rfl(i,j,nir)-rfl(i,j,grn))-2.5*(rfl(i,j,red)-rfl(i,j,grn))) / $
    sqrt((2.0*rfl(i,j,nir)+1)^2.0 - (6.0*rfl(i,j,nir)) + (5.0*sqrt(rfl(i,j,red))) - 0.5)
    
  ;13. MCARI/MTVI2
  indx(i,j,11) = indx(i,j,4) / indx(i,j,10)
  
  ;13. DCNI   !!! we're using 750 nm instead of 720 nm !!!
  indx(i,j,12) = (rfl(i,j,nir)-rfl(i,j,redge)) / (rfl(i,j,redge) - rfl(i,j,red)) / (rfl(i,j,nir)-rfl(i,j,red)+0.03)

  ;14. MTCI/NDVI
  indx(i,j,13) = indx(i,j,9) / indx(i,j,0)
  
  ;15. GCI/NDVI
  indx(i,j,14) = indx(i,j,2) / indx(i,j,0)
  
  ;16. TVI
  ;indx(i,j,15) = 0.5*(120*(rfl(i,j,nir)-rfl(i,j,grn))-200*(rfl(i,j,red)-rfl(i,j,grn)))
     
  endfor
  print, float(i)/float(nsamples)
endfor
  
openw, lun, outfile, /GET_LUN
writeu, lun, indx
close, lun
  
end