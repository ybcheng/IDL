;Batch processing cross-track illumination correction on mini-MCA images
;Yen-Ben Cheng
;August 2014

pro batchCrsTrk, imagedirectory, imagesuffix, range_dir, method, order, pos, outdirectory, outsuffix, outtifsuffix

;batchCrsTrk, 'C:\Users\Yen-Ben\Documents\IDL\CrsTrk\', 'TIF', 0, 1, 2, [0,1,2,3,4,5], 'C:\Users\Yen-Ben\Documents\IDL\CrsTrk\1\', '_crsTrk1.img', '_crsTrk1'
;batchCrsTrk, 'C:\Users\Yen-Ben\Documents\IDL\CrsTrk\1\TIF\', 'TIF', 1, 1, 2, [0,1,2,3,4,5], 'C:\Users\Yen-Ben\Documents\IDL\CrsTrk\2\', '_crsTrk2.img', '_crsTrk2'

;batch process cross-track illumination correction on multiple files

;!!the program assumes all the images have the same size and are in TIF format!!
;this program will output files as ENVI standard files as well as in TIF format
;make to have folders 1, 1\TIF, 2, 2\TIF created where input files are

;cross_track_correciton_doit parameters:
;range_dir: 0: across the samples of a line, 1:across the lines of a sample 
;method = 0: additive; 1:multiplicative correction
;order = specify the degree of polynomial of the correction curve
;pos: which bands to process, [0,1,2,3,4,5] means we process all the six bands

 
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
  
  envi_file_query, fid, ns=nsamples, nl=nlines, nb=nbands, interleave=interleave, data_type=data_type 
  dims=[-1L, 0, nsamples-1, 0, nlines-1]  ;this one's for cross_track_correction_doit
  
  ;these two are for write_tiff
  temparr = uintarr(nsamples, nlines, nbands)
  tifarr = uintarr(nbands, nsamples, nlines)
  
  ;cross track correction
  envi_doit, 'cross_track_correction_doit', $
    fid=fid, dims=dims, range_dir=range_dir, out_name=outfilenamearray[j], $
    method=method, order=order, pos=pos, r_fid=fidd
  
  envi_file_mng, id=fid, /remove
  envi_file_mng, id=fidd, /remove    
  
  ;now export the file as TIF format
  openr, lun, outfilenamearray[j], /get_lun
  readu, lun, temparr
  close, lun
  
  for m=0,nsamples-1 do begin
    for n=0,nlines-1 do begin
      for k=0,nbands-1 do begin
        tifarr(k,m,n) = temparr(m,n,k)
      endfor
    endfor
  endfor
  
  write_tiff, outtifarray[j], tifarr, /SHORT

  print, outtifarray[j] 
endfor


end
