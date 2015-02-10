;Batch processing resize images
;Yen-Ben Cheng
;Feburary, 2015

pro batchResize, imagedirectory, imagesuffix, RFACT, INTERP, pos, outdirectory, outsuffix, outtifsuffix

;batchResize, 'C:\Users\Yen-Ben\Documents\IDL local\resize\', 'jpg', [2,2], 3, [0,1,2], 'C:\Users\Yen-Ben\Documents\IDL local\resize\1\', '_res.img', '_res'

;batch process resize on multiple files

;this program will output files as ENVI standard files as well as in TIF format
;make sure to have folders 1, 1\TIF,  where input files are

;resize_doit parameters:
;RFACT: two-element array holding the rebin factors for x and y. A value of 1 does not change the size of the data. Values less than 1 cause the size to increase; values greater than 1 cause the size to decrease.
;INTERP = 0: Nearest neighbor, 1: Bilinear, 2: Cubic convolution, 3: Pixel aggregate
;pos: which bands to process, [0,1,2] means we process all the RGB bands

 
e=ENVI(/headless)

;ENVI, /RESTORE_BASE_SAVE_FILES
;ENVI_BATCH_INIT, /NO_STATUS_WINDOW

wildcard='*'

;search and create input files array
imagenamearray = file_search((imagedirectory + wildcard + imagesuffix))
numimages = n_elements(imagenamearray)

;create file base name array
dotsuffix = '.' + imagesuffix
basenamearray=strarr(numimages)
for i=0, numimages-1 do begin
  basenamearray[i] = file_basename(imagenamearray[i], dotsuffix)
endfor
  
;create output files array
outfilenamearray=strarr(numimages)
for i=0, numimages-1 do begin
  outfilenamearray[i] = outdirectory + basenamearray[i] + outsuffix
endfor  

;create output TIF files array, maybe skip the ooutsuffix so it's easier for Agisoft
outtifarray=strarr(numimages)
for i=0, numimages-1 do begin
  outtifarray[i] = outdirectory + 'TIF\' + basenamearray[i] + outtifsuffix + '.' + imagesuffix
endfor

;going through for loops to process every file
for j=0, numimages-1 do begin
    
  envi_open_file, imagenamearray[j], r_fid=fid
  if (fid eq -1) then return  
  
  envi_file_query, fid, ns=nsamples, nl=nlines, nb=nbands, interleave=interleave, data_type=data_type, dims=dims 
  ;dims=[-1L, 0, nsamples-1, 0, nlines-1]  ;this one's for cross_track_correction_doit
  
  ;resize
  envi_doit, 'resize_doit', $
    fid=fid, dims=dims, INTERP=interp, out_name=outfilenamearray[j], $
    pos=pos, r_fid=fidd, rfact=rfact
  
  envi_file_query, fidd, ns=nsamples, nl=nlines, nb=nbands, dims=dims
  
  ;this is for write_tiff
  temparr = BYTARR(nsamples, nlines, nbands)

  for i = 0, nbands-1 do begin
    temparr[*,*,i] = envi_get_data(fid=fidd, dims=dims, pos=i)
  endfor
    
  envi_file_mng, id=fid, /remove
  envi_file_mng, id=fidd, /remove    
  
  ;this is for write_tiff
  tifarr = bytarr(nbands, nsamples, nlines)
  
  for m=0,nsamples-1 do begin
    for n=0,nlines-1 do begin
      for k=0,nbands-1 do begin
        tifarr(k,m,n) = temparr(m,n,k)
      endfor
    endfor
  endfor
  
  write_tiff, outtifarray[j], tifarr

  print, outtifarray[j] 
endfor


end
