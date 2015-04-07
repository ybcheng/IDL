;manual spatially subsetting images
;Yen-Ben Cheng
;December 2014

FUNCTION cutFunc, infile, subimg, outfile

  ;cutFunc, 'C:\Users\Yen-Ben\Documents\IDL\cut\input.tif', [100,100,1180, 924], 'C:\Users\Yen-Ben\Documents\IDL\cut\output.tif'

  ;this program is designed to manaully spatially subsetting images, instead of using the default ENVI function
  ;it will operate on all of the bands
  ;the subimg vector defines x and y range of the spatial subset in the format of [Xstart, Ystart, Xend, Yend]
  
  
  ;e=ENVI(/headless)

  ;open and read the input image file
  envi_open_file, infile, r_fid=fid
  if (fid eq -1) then print, 'file does not exist'

  envi_file_query, fid, ns=nsamples, nl=nlines, nb=nbands, interleave=interleave, data_type=data_type, dims=dims
  
  CASE data_type OF
	1: inparr = BYTARR  (nsamples, nlines, nbands) ;input data type is byte
    2: inparr = INTARR  (nsamples, nlines, nbands) ;input data type is integer
    4: inparr = FLTARR  (nsamples, nlines, nbands) ;input data type is floating point
    12: inparr = UINTARR(nsamples, nlines, nbands) ;input data type is unsigned integer
    ELSE: BEGIN
      ENVI_REPORT_ERROR, 'check input file data type', /cancel
      ;RETURN
    END
  ENDCASE 
  
  for i = 0, nbands-1 do begin
    inparr[*,*,i] = envi_get_data(fid=fid, dims=dims, pos=i)
  endfor
  
  envi_file_mng, id=fid, /remove
  
  outarr = inparr (subimg[0]:subimg[2], subimg[1]:subimg[3], 0:nbands-1)
  
  ;CASE interleave OF
  ;  0: BEGIN  ;input file is in BSQ format
  ;    PRINT, 'input file is in BSQ format:',nsamples,',',nlines,',',nbands
  ;    CASE data_type OF
  ;      1: inparr = BYTARR  (nsamples, nlines, nbands) ;input data type is byte
  ;      2: inparr = INTARR  (nsamples, nlines, nbands) ;input data type is integer
  ;      4: inparr = FLTARR  (nsamples, nlines, nbands) ;input data type is floating point
  ;      12: inparr = UINTARR(nsamples, nlines, nbands) ;input data type is unsigned integer
  ;      ELSE: BEGIN
  ;        ENVI_REPORT_ERROR, 'check input file data type', /cancel
  ;        ;RETURN
  ;      END
  ;    ENDCASE
  ;    openr, lun, infile, /get_lun
  ;    readu, lun, inparr
  ;    close, lun
  ;    outarr = inparr (subimg[0]:subimg[2], subimg[1]:subimg[3], 0:nbands-1)
  ;  END
  ;  1: BEGIN  ;input file is in BIL format
  ;    PRINT, 'input file is in BIL format:',nsamples,',',nbands,',',nlines
  ;    CASE data_type OF
  ;      1: inparr = BYTARR  (nsamples, nbands, nlines) ;input data type is byte
  ;      2: inparr = INTARR  (nsamples, nbands, nlines) ;input data type is integer
  ;      4: inparr = FLTARR  (nsamples, nbands, nlines) ;input data type is floating point
  ;      12: inparr = UINTARR(nsamples, nbands, nlines) ;input data type is unsigned integer
  ;      ELSE: BEGIN
  ;        ENVI_REPORT_ERROR, 'check input file data type', /cancel
  ;        ;RETURN
  ;      END
  ;    ENDCASE
  ;    openr, lun, infile, /get_lun
  ;    readu, lun, inparr
  ;    close, lun
  ;    outarr = inparr (subimg[0]:subimg[2], 0:nbands-1, subimg[1]:subimg[3])
  ;  END
  ;  2: BEGIN  ;input file is in BIP format
  ;    PRINT, 'input file is in BIP format:',nbands,',',nsamples,',',nlines
  ;    CASE data_type OF
  ;      1: inparr = bytarr  (nbands, nsamples, nlines) ;input data type is byte
  ;      2: inparr = intarr  (nbands, nsamples, nlines) ;input data type is integer
  ;      4: inparr = fltarr  (nbands, nsamples, nlines) ;input data type is floating point
  ;      12: inparr = uintarr(nbands, nsamples, nlines) ;input data type is unsigned integer
  ;      ELSE: BEGIN
  ;        ENVI_REPORT_ERROR, 'check input file data type', /cancel
  ;        ;RETURN
  ;      END
  ;    ENDCASE
  ;    openr, lun, infile, /get_lun
  ;    readu, lun, inparr
  ;    close, lun
  ;    outarr = inparr (0:nbands-1, subimg[0]:subimg[2], subimg[1]:subimg[3])
  ;  END
  ;ENDCASE
  
  tifarr = uint(outarr)
  
  ;for m=0,nsamples-1 do begin
  ;  for n=0,nlines-1 do begin
  ;    for k=0,nbands-1 do begin
  ;      tifarr(k,m,n) = outarr(m,n,k)
  ;    endfor
  ;  endfor
  ;endfor
  
  write_tiff, outfile, tifarr, /SHORT

  RETURN, outfile

END