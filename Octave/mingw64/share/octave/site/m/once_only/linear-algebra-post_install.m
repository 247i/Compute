## Copyright (C) 2026 Philip Nienhuis
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {} {@var{retval} =} post_install (@var{desc})
##
## @seealso{}
## @end deftypefn

function retval = post_install (desc)

  retval = 0;

  ## Remove funm.m for Octave >= 11.1.0
  file_to_be_deleted = "funm.m";
  if (compare_versions (ver ("octave").Version, "11.1.0", ">="))
    nam = [desc.dir filesep file_to_be_deleted];
    [st, msg] = unlink (nam);
    if (st < 0)
      warning ("pkg: couldn't delete file '%s'\n%s\n", nam, msg);
    else
      ## Also remove from INDEX
      fid = fopen ([desc.dir filesep "packinfo" filesep "INDEX"], "r");
      txt = fread (fid, Inf, "*char")';
      fclose (fid);
      txt = regexprep (txt, '\W*funm', "");
      fid = fopen ([desc.dir filesep "packinfo" filesep "INDEX"], "w");
      fprintf (fid, "%s", txt);
      fclose (fid);
    endif
  endif

endfunction
