## Copyright (C) 2019 Anthony Morast <anthony.a.morast@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {Depreciation =} depstln (@var{Cost}, @var{Salvage}, @var{Life})
##
## Calculates straight-line depreciation (i.e., (Cost - Salvage) / Life).
##
## @end deftypefn

function Depreciation = depstln (Cost, Salvage, Life)
  if (nargin != 3 )
    print_usage ();
  endif
  Depreciation = (Cost - Salvage) ./ Life;
endfunction

## Tests
%!assert (depstln (13000, 1000, 10), 1200)
%!assert (depstln ([1000 200 300], [200 10 5], [10 10 4]), [80 19 73.75])
%!assert (depstln (1000, 2000, 10), -100)
%!assert (depstln (2000, 0, 1), 2000)
%!assert (depstln (234, 233, 10), 0.1)
