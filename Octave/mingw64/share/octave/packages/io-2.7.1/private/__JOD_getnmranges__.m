## Copyright (C) 2017-2026 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{retval} =} __JOD_getnmranges__ (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2015-09-20

function [nmr] = __JOD_getnmranges__ (ods)

  try
    ## Works only in jOpenDocument 1.5+
    nmrs = ods.workbook.getRangesNames ();
    nnmr = nmrs.size ();
    anmr = nmrs.toArray ();
    nmr = cell (nnmr, 3);
    for inmr=1 : nnmr
      rg = ods.workbook.getRange (anmr(inmr)).toString ();
      rg = strsplit (rg,".");
      nmr{inmr, 3} = [rg{2:3}];
      nmr{inmr, 2} = rg{1};
      nmr{inmr, 1} = anmr(inmr);
    endfor
  catch
  ## Just a stub. Named ranges do not work in earlier jOpenDocument
    nmr = cell (0, 3);
  end_try_catch

endfunction
