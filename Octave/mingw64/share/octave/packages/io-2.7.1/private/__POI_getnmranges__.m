## Copyright (C) 2015-2026 Philip Nienhuis
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
## @deftypefn {Function File} {@var{retval} =} __POI_getnmranges__ (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2015-09-20

function [nmr] = __POI_getnmranges__ (xls)

  ii = 0;
  inmr = 0;
  nmr = cell (0, 3);
  poiv = javaObject ("org.apache.poi.Version").getVersion();
  if (compare_versions (poiv, "5.0.0", "<"))
    ## Because there's no POI call to get all named ranges, use a try-catch
    try
      while (ii  < 1e5)                  ## Should suffice
        nm = xls.workbook.getNameAt (ii);
        ## If we get here, the name at index ii exists
        rg = nm.getRefersToFormula ();
        rg = strrep (rg(index (rg, "!") + 1:end), "$", "");
        ## Check if looks like a range
        mtch = cell2mat (regexp (rg, ...
                         '(^[A-Za-z]+[0-9]+){1}(:[A-Za-z]+[0-9]+$)?', "tokens"));
        if (! isempty (mtch) && strcmp ([mtch{:}], rg))
          ## Yep, a range
          ++inmr;
          nmr{inmr, 1} = nm.getNameName ();
          nmr{inmr, 2} = nm.getSheetName ();
          nmr{inmr, 3} = rg;
        endif
        ++ii;
      endwhile
    end_try_catch
  else
    ## POI > 5.0.0 finally has a method to request Named Ranges
    nmrs = xls.workbook.getAllNames ();
    nnmr = nmrs.size ();
    nmr = cell (nnmr, 3);
    for inmr=1 : nnmr
      nm = nmrs.get (inmr-1);
      rg = nm.getRefersToFormula ();
      rg = strrep (rg(index (rg, "!") + 1:end), "$", "");
      ## Check if looks like a range
      mtch = cell2mat (regexp (rg, ...
                       '(^[A-Za-z]+[0-9]+){1}(:[A-Za-z]+[0-9]+$)?', "tokens"));
      if (! isempty (mtch) && strcmp ([mtch{:}], rg))
        ## Yep, a range
        nmr{inmr, 3} = rg;
        nmr{inmr, 1} = nm.getNameName ();
        nmr{inmr, 2} = nm.getSheetName ();
      endif
    endfor
  endif

endfunction
