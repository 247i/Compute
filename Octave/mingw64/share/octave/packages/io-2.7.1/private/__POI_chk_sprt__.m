## Copyright (C) 2014-2026 Philip Nienhuis
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
## @deftypefn {Function File} {@var{vargout} =} __POI_chk_sprt__ (@var{varargin})
## Undocumented internal function
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2014-10-31

function [chk, missing1, missing2] = __POI_chk_sprt__ (jcp, dbug=0)

  chk = 0;
  ## First Check basic .xls (BIFF8) support
  if (dbug > 1)
    printf ("\nBasic POI (.xls) <poi> <poi-ooxml> <commons-math>:\n");
  endif
  ## Below entries1 order = vital as each POI version needs additional jars
  entries1 = {{"apache-poi.", "poi-3", "poi-4", "poi-5"}, ...
              {"apache-poi-ooxml.", "poi-ooxml-3", "poi-ooxml-4", "poi-ooxml-5"}, ...
              "commons-math"};
  ## Only under *nix we might use brute force: e.g., strfind (javaclasspath, classname)
  ## as javaclasspath is one long string. Under Windows however classpath is a cell array
  ## so we need the following more subtle, platform-independent approach:
  [jpchk1, missing] = chk_jar_entries (jcp, entries1, dbug);
  missing1 = entries1 (find (missing));
  try
    ## POI >= 4.0 needs another jar here
    poiv = javaObject ("org.apache.poi.Version").getVersion();
    if (compare_versions (poiv, "4.0.0", "<"))
      ic = find (cellfun ("ischar", missing1));
      id = find (strncmpi ("commons-math", missing1(ic), 1));
      missing1(ic(id)) = [];
      jpchk1++;
      if (dbug > 1)
        printf ("  commons-math not needed for POI <= 5.0\n");
      endif
    endif
  end_try_catch
  if (jpchk1 >= numel (entries1))
    chk = 1;
    if (dbug > 1)
      printf ("  => Apache (POI) OK\n");
    endif
  elseif (dbug > 1);
      printf ("  => Not all classes (.jar) required for POI in classpath\n");
  endif

  ## Next, check OOXML support
  if (dbug > 1)
    printf ("\nPOI OOXML (.xlsx) <xbean/xmlbean> <poi-ooxml-schemas/lite> <dom4j>/< commons...>:\n");
  endif
  ## Each next POI version needs more jars, so order below is vital
  entries2 = {{"xbean", "xmlbean"}, {"apache-poi-ooxml-schemas", ...
              "poi-ooxml-schemas", "poi-ooxml-lite"}, "commons-collections", ...
              "commons-compress", "commons-io", "log4j-api", "log4j-core"};
  [jpchk2, missing] = chk_jar_entries (jcp, entries2, dbug);
  missing2 = entries2 (find (missing));
  ## Check if common-collections4 is req'd (only for POI >= 3.15)
  try         ## ...cause POI may not yet be in the javaclasspath ...
    poiv = javaObject ("org.apache.poi.Version").getVersion();
    ## Stuff required only for POI-3.15+
    if (compare_versions (poiv, "3.14", "<="))
      ## Remove commons-collections from missing2
      ic = find (cellfun (@ischar, missing2));
      id = find (strncmpi ("commons-collections", missing2(ic), 19));
      missing2(ic(id)) = [];
      jpchk2++;
      if (dbug > 2)
        printf ("  commons-collections4 not needed for POI <= 3.14\n");
      endif
    endif
    ## Stuff required only for POI-4 and up
    if (compare_versions (poiv, "4.0", "<") && ...
        any (strncmpi (missing2, "commons-compress", 16)))
      ## Remove commons-compress from missing2
      ic = find (cellfun (@ischar, missing2));
      id = find (strncmpi ("commons-compress", missing2(ic), 16));
      missing2(ic(id)) = [];
      jpchk2++;
      if (dbug > 2)
        printf ("  commons-compress not needed for POI <= 4.0\n");
      endif
    endif
    ## Stuff needed only for POI-5.1+
    if (compare_versions (poiv, "5.1", "<") && ...
        any (strncmpi (missing2(:), "commons-io", 16)))
      ## Remove commons-io from missing2
      ic = find (cellfun (@ischar, missing2));
      id = find (strncmpi ("commons-io", missing2(ic), 16));
      missing2(ic(id)) = [];
      jpchk2++;
      if (dbug > 2)
        printf ("  commons-io not needed for POI <= 5.0\n");
      endif
      ## Remove log4j (2 jars) from missing2
      ic = find (cellfun (@ischar, missing2));
      id = find (strncmpi ("log4j", missing2(ic), 5));
      missing2(ic(id)) = [];
      jpchk2 += 2;
      if (dbug > 2)
        printf ("  log4j not needed for POI <= 5.0\n");
      endif
    endif
  end_try_catch

  if (jpchk2 >= numel (entries2))
    ## Only bump chk if basic classes were all found
    if (chk)
      ++chk;
    endif
    if (dbug > 1)
      printf ("  => POI OOXML OK\n");
    endif
  elseif (dbug > 1)
      printf ("  => Some classes for POI OOXML support missing\n");
  endif

endfunction
