;Batch spatially subsetting on images in a folder
;Yen-Ben Cheng
;December 2014

pro batchCut, imagedirectory, imagesuffix, subimg, outdirectory, outsuffix, outtifsuffix

  ;batchCut, 'C:\Users\Yen-Ben\Documents\IDL\cut\', 'TIF', [100,100, 1180, 924], 'C:\Users\Yen-Ben\Documents\IDL\cut\1\', '_cut.img', ''

  ;batch spatially subsetting on multiple files

  ;this program will output files as ENVI standard files as well as in TIF format
  ;make to have folders 1, 1\TIF, 2, 2\TIF created where input files are


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
    outtifarray[j] = cutFunc(imagenamearray[j], subimg, outtifarray[j])
    print, outtifarray[j]
  endfor


end
