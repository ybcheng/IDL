;Batch calculating mean value of each image in a folder
;Yen-Ben Cheng
;January 2015

pro batchAVG, imagedirectory, imagesuffix, ncolumns, nrows, nbands, outfile

  ;batchAVG, 'C:\Users\Yen-Ben\Documents\IDL\avg\', 'bin', 1024, 768, 1, 'C:\Users\Yen-Ben\Documents\IDL\avg\avg.csv'
  ;
  ;this program was design to analyze the temporal trend when testing the atom1024 high res thermal camera
  ;all images have the same size 1024 x 768 x 1, integer format
  ;the program will read in the files, calculate average value, then output to a csv file
 
  ;e=ENVI(/headless)

  wildcard='*'

  ;search and create input files array
  imagenamearray = file_search(imagedirectory + wildcard + imagesuffix)
  numimages = n_elements(imagenamearray)
  
  ;floating point arry to store average of each of the images
  imgavgarr = fltarr(numimages)
  
  ;going through for loops to process every file
  for i=0, numimages-1 do begin
    
    ;integer array for each image
    img = intarr(ncolumns, nrows, nbands)
    
    openr, lun, imagenamearray(i), /get_lun
    readu, lun, img
    close, lun
    FREE_LUN, lun
    
    img = FLOAT(img)
    imgavgarr(i) = mean(img)
    
    print, float(i) / float(numimages)
  
  endfor

write_csv, outfile, imgavgarr

end
