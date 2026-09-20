## Copyright (C) 2018-2019 Rik Wehbring
##
## This file is part of Octave.
##
## Octave is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {} {@var{tf} =} isfile (@var{f})
## Return true if @var{f} is a regular file and false otherwise.
##
## If @var{f} is a cell array of strings, @var{tf} is a logical array of the
## same size.
## @seealso{isfolder, exist, stat, is_absolute_filename, is_rooted_relative_filename}
## @end deftypefn

function retval = __isfile__ (f)

  ## copied from Octaves isfile() for compatibility with Octave < 5.1

  if (nargin != 1)
    print_usage ();
  endif

  if (! (ischar (f) || iscellstr (f)))
    error ("isfile: F must be a string or cell array of strings");
  endif

  f = cellstr (f);
  retval = false (size (f));
  for i = 1:numel (f)
    [info, err] = stat (f{i});
    retval(i) = (! err && S_ISREG (info.mode));
  endfor

endfunction
