rfl = intarr (1280, 1024, 1)

openr, lun, 'd:\IDL\raw\TTC00800.RAW', /get_lun
readu, lun, rfl
close, lun

end
