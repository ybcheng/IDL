;manual cross track correction
;Yen-Ben Cheng
;November 2014

pro mCrsTrk, infile, outfile

  ;mCrsTrk, 'C:\Users\Yen-Ben\Documents\IDL\CrsTrk\input.tif', 'C:\Users\Yen-Ben\Documents\IDL\CrsTrk\output.tif'

  ;this program is designed to correct the gradient seen in thermal images due to long flying time
  ;
  e=ENVI(/headless)

  ;open and read the input image file
  envi_open_file, infile, r_fid=fid
  if (fid eq -1) then return

  envi_file_query, fid, ns=nsamples, nl=nlines, nb=nbands, interleave=interleave, data_type=data_type
  envi_file_mng, id=fid, /remove
  
  CASE interleave OF
    0: BEGIN  ;input file is in BSQ format
      PRINT, 'input file is in BSQ format:',nsamples,',',nlines,',',nbands
      CASE data_type OF
        1: inparr = BYTARR  (nsamples, nlines, nbands) ;input data type is byte
        2: inparr = INTARR  (nsamples, nlines, nbands) ;input data type is integer
        4: inparr = FLTARR  (nsamples, nlines, nbands) ;input data type is floating point
        12: inparr = UINTARR(nsamples, nlines, nbands) ;input data type is unsigned integer
        ELSE: BEGIN
          ENVI_REPORT_ERROR, 'check input file data type', /cancel
          RETURN
        END
      ENDCASE
      ;openr, lun, infile, /get_lun
      ;readu, lun, inparr
      ;close, lun
      inparr = read_tiff(infile)
      inparr = FLOAT(inparr)
    END
    1: BEGIN  ;input file is in BIL format
      PRINT, 'input file is in BIL format:',nsamples,',',nbands,',',nlines
      CASE data_type OF
        1: inparr = BYTARR  (nsamples, nbands, nlines) ;input data type is byte
        2: inparr = INTARR  (nsamples, nbands, nlines) ;input data type is integer
        4: inparr = FLTARR  (nsamples, nbands, nlines) ;input data type is floating point
        12: inparr = UINTARR(nsamples, nbands, nlines) ;input data type is unsigned integer
        ELSE: BEGIN
          ENVI_REPORT_ERROR, 'check input file data type', /cancel
          RETURN
        END
      ENDCASE
      openr, lun, infile, /get_lun
      readu, lun, inparr
      close, lun
      inparr = FLOAT(inparr)
      inparr = TRANSPOSE(inparr, [0,2,1])
    END
    2: BEGIN  ;input file is in BIP format
      PRINT, 'input file is in BIP format:',nbands,',',nsamples,',',nlines
      CASE data_type OF
        1: inparr = bytarr  (nbands, nsamples, nlines) ;input data type is byte
        2: inparr = intarr  (nbands, nsamples, nlines) ;input data type is integer
        4: inparr = fltarr  (nbands, nsamples, nlines) ;input data type is floating point
        12: inparr = uintarr(nbands, nsamples, nlines) ;input data type is unsigned integer
        ELSE: BEGIN
          ENVI_REPORT_ERROR, 'check input file data type', /cancel
          RETURN
        END
      ENDCASE
      openr, lun, infile, /get_lun
      readu, lun, inparr
      close, lun
      inparr = FLOAT(inparr)
      inparr = TRANSPOSE(inparr, [1,2,0])
    END
  ENDCASE
  
  xarr = fltarr(nsamples)
  yarr = fltarr(nsamples)
  
  FOR i = 0, nsamples-1 DO BEGIN
    xarr(i)=i
    sum = 0.0
    count=0.0
    FOR j = 0, nlines-1 DO BEGIN
      if (inparr(i,j,0) NE 0) then begin
      sum = sum + inparr(i,j,0)
      count = count +1.0  
      endif
    ENDFOR
    yarr(i) = sum / count
  ENDFOR
  
  count = 0
  for i = 0, nsamples-1 do begin
    if (FINITE(yarr(i)) EQ 1) then begin
      count = count + 1
    endif
  endfor

  X = fltarr(count)
  Y = fltarr(count)
  
  indx = 0
  for i = 0,nsamples-1 do begin
    if (FINITE(yarr(i)) EQ 1) then begin
      X(indx) = xarr(i)
      Y(indx) = yarr(i)
      indx = indx + 1
    endif
  endfor
  
  ;use 1st degree polynomial to fit the gradient
    
  print, xarr(0), xarr(100), xarr(nsamples-1)
  print, yarr(0), yarr(100), yarr(nsamples-1)
  
  
  results = poly_fit(X, Y, 1)
  
  print, results
  
  ;apply correction to output array
  outarr = fltarr (nsamples, nlines, 1)
  
  FOR i = 0, nsamples-1 DO BEGIN
    FOR j = 0, nlines-1 DO BEGIN
      if (inparr(i,j,0) NE 0) then begin
        outarr(i,j,0) = inparr(i,j,0)-results(1)*xarr(i)
      endif
    ENDFOR
  ENDFOR
  
  outarr = uint(outarr)
  
  tifarr = uintarr(nbands, nsamples, nlines)
  
  for m=0,nsamples-1 do begin
    for n=0,nlines-1 do begin
      for k=0,nbands-1 do begin
        tifarr(k,m,n) = outarr(m,n,k)
      endfor
    endfor
  endfor
  
  write_tiff, outfile, outarr, /SHORT
  
END