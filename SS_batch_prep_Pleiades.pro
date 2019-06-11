;Simple script to batch pre-processing Pleiades data 
;
;The script does two things:
;1. export original PAN and MS data to TIFF format
;2. perform Radiometric Calibration function on MS data and 
;   produce Top-Of-Atmosphere reflectance images in TIFF format
;   
;This is written to process Pleiades imagery specifically
;It's not very flexible, largely depends on directory structure and nomenclature of files
;CHECK and carefully EDIT the input parameters
;
;load e = ENVI(/HEADLESS) before compilation
;
;This script will skip processing if same output file name already exists
;
;Yen-Ben Cheng
;March 2017
;
pro SS_batch_prep_Pleiades

; Start the application
e = ENVI(/HEADLESS)

; !!!! CHECK and carefully EDIT the following input
;----------------------------------------------------------------------------
date = '20190529' ;date is used in output filenames

imagedirectory = 'R:\IID_SaltonSea\BaseData\Raster\pleiades\20190529\originals'
outdirectory = 'R:\IID_SaltonSea\BaseData\Raster\pleiades\20190529\'

;imagedirectory = 'R:\OwensLake\raster\Pleiades\20190423\'
;outdirectory = 'R:\OwensLake\raster\Pleiades\20190423\'

;imagedirectory = 'R:\Kinross\\geodata\raster\Pleiades\20180311\'
;outdirectory = 'R:\Kinross\geodata\raster\Pleiades\20180311\'

;the script is not smart enough to separate PAN and MS data
;therefore, use img_type = 11L for PAN and 44L for MS data
;img_type = 11L ;for PAN
img_type = 44L ;for MS

;scene name is used in output filenames
;use this parameter to specify the position of the scene name in the file_list string (separated by "\")
scene_pos = 8
;----------------------------------------------------------------------------


CD, imagedirectory

;build list of files to be processed
IF img_type EQ 11 THEN wildcard = 'DIM*_P_*XML' ELSE $
IF img_type EQ 44 THEN wildcard = 'DIM*_MS_*XML'

file_list = FILE_SEARCH(imagedirectory, wildcard)
IF STRLEN(STRTRIM(file_list[0])) lt 1 then begin
  PRINT, 'Error finding files in directory '
  RETURN
ENDIF

;looping through files and perform relevant processing
;for PAN img, only export to TIFF to be performed
;for MS img, calculate TOA reflectance and export both DN and REFL to TIFF
FOR i = 0, N_ELEMENTS(file_list)-1 DO BEGIN
  PRINT, 'Processing: ' + file_list[i]
  extr_scene = STRSPLIT(file_list[i], '\', /EXTRACT)
  scene_name = extr_scene[scene_pos - 1]
  raster = e.OpenRaster(file_list[i])
  IF img_type EQ 11 THEN BEGIN
    out_dn_path = outdirectory + date + '_' + scene_name + '_pan_dn.tif'
    IF FILE_TEST(out_dn_path) EQ 1 THEN BEGIN
      PRINT, 'File already exists, skipped: ' + out_dn_path
    ENDIF ELSE BEGIN
      raster.Export, out_dn_path, 'TIFF'
      PRINT, 'Generated: ' + out_dn_path 
    ENDELSE
  ENDIF ELSE BEGIN
    out_dn_path = outdirectory + date + '_' + scene_name + '_ms_dn.tif'
    IF FILE_TEST(out_dn_path) EQ 1 THEN BEGIN
      PRINT, 'File already exists, skipped: ' + out_dn_path
    ENDIF ELSE BEGIN
      raster.Export, out_dn_path, 'TIFF'
    PRINT, 'Generated: ' + out_dn_path
    ENDELSE
    out_refl_path = outdirectory + date + '_' + scene_name + '_ms_refl.tif' 
    IF FILE_TEST(out_refl_path) EQ 1 THEN BEGIN
      PRINT, 'File already exists, skipped: ' + out_refl_path
    ENDIF ELSE BEGIN
      refl_raster = ENVICalibrateRaster(raster, CALIBRATION='Top-of-Atmosphere Reflectance')
      refl_raster.Export, out_refl_path, 'TIFF'
      PRINT, 'Generated: ' + out_refl_path
    ENDELSE
  ENDELSE
  raster.Close
ENDFOR


END
