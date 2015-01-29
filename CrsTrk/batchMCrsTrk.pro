;Batch manually processing cross-track illumination correction on images in a folder
;Yen-Ben Cheng
;November 2014

pro batchMCrsTrk, imagedirectory, imagesuffix, outdirectory, outsuffix, outtifsuffix

;batchMCrsTrk, 'C:\Users\Yen-Ben\Documents\IDL\CrsTrk\', 'TIF', 'C:\Users\Yen-Ben\Documents\IDL\CrsTrk\1\', '_crsTrk1.img', '_crsTrk1'

;batch process cross-track illumination correction on multiple files

;this program will output files as ENVI standard files as well as in TIF format
;make to have folders 1, 1\TIF, 2, 2\TIF created where input files are

 
;e=ENVI(/headless)

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
  outtifarray[j] = mCrsTrkFunc(imagenamearray[j], outtifarray[j])
  print, outtifarray[j] 
endfor


end
