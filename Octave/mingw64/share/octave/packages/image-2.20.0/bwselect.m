## Copyright (C) 1999 Andy Adler <adler@sce.carleton.ca>
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
## @deftypefn {Function File} {[@var{imout}, @var{idx}] =} bwselect(@var{im}, @var{cols}, @var{rows}, @var{connect})
## Select connected regions in a binary image.
##
## @table @code
## @item @var{im}
## binary input image
## @item [@var{cols}, @var{rows}]
## vectors of starting points (x,y)
## @item @var{connect}
## connectedness 4 or 8. default is 8
## @item @var{imout}
## the image of all objects in image im that overlap
## pixels in (cols,rows)
## @item @var{idx}
## index of pixels in imout
## @end table
## @end deftypefn

function [imout, idx] = bwselect (im, cols, rows, connect)

  if (nargin < 3 || nargin > 4)
    print_usage();
  elseif (nargin == 3)
    connect = 8;
  endif

  if (connect != 4 && connect != 8)
    error ("bwselect: connect should be 4 or 8")
  endif

  [~, idx] = bwfill (! im, cols, rows, 12 - connect);

  imout = false (size (im));
  imout(idx) = true;

  if (nargout == 0)
     figure; imshow(imout);
  endif

endfunction

%!test
%! BW = zeros(5, 'logical');
%! BW(3, 4) = 1;
%! BW(4, 3) = 1;
%! res8 = bwselect (BW, 3, 4, 8);
%! assert (res8, BW)
%! res4 = bwselect (BW, 3, 4, 4);
%! res8_expected = BW;
%! res8_expected(4, 3) = 1;
%! assert (res8, res8_expected)

%!test
%! A = [0 1 0 0 1; 1 0 1 0 0; 1 0 1 1 0; 1 1 1 0 0; 1 0 0 1 0];
%! R4 = zeros(5, 'logical');
%! R4(1, 1) = 1;
%! R8 = logical([1 0 1 1 0; 0 1 0 1 1; 0 1 0 0 1; 0 0 0 1 1; 0 1 1 0 1]);
%! out = bwselect (A, 1, 1, 4);
%! assert (out, zeros (5, 'logical'))
%! out = bwselect (A, 1, 1, 8);
%! assert (out, zeros (5, 'logical'))
%! out = bwselect (! A, 1, 1, 4);
%! assert (out, R4)
%! out = bwselect (! A, 1, 1, 8);
%! assert (out, R8)
%!
%! B4 = logical([0 0 0 0 0; 1 0 1 0 0; 1 0 1 1 0; 1 1 1 0 0; 1 0 0 0 0]);
%! B8 = logical([0 1 0 0 0; 1 0 1 0 0; 1 0 1 1 0; 1 1 1 0 0; 1 0 0 1 0]);
%! out = bwselect (A, 3, 3, 4);
%! assert (out, B4)
%! out = bwselect (A, 3, 3, 8);
%! assert (out, B8)
%! out = bwselect (A, 3, 3);
%! assert (out, B8)
%!
%! C4 = logical ([0 0 1 1 0; 0 0 0 1 1; 0 0 0 0 1; 0 0 0 1 1; 0 0 0 0 1]);
%! C8 = logical ([1 0 1 1 0; 0 1 0 1 1; 0 1 0 0 1; 0 0 0 1 1; 0 1 1 0 1]);
%! out = bwselect (! A, 3, 1, 8);
%! assert (out, C8)
%! out = bwselect (! A, 3, 1);
%! assert (out, C8)
%! out = bwselect (! A, 3, 1, 4);
%! assert (out, C4)
%!
%! D4 = logical ([0 0 0 0 0; 1 0 1 0 0; 1 0 1 1 0; 1 1 1 0 0; 1 0 0 0 0]);
%! D8 = logical ([0 1 0 0 0; 1 0 1 0 0; 1 0 1 1 0; 1 1 1 0 0; 1 0 0 1 0]);
%! out = bwselect (A, [3 1], [1 3], 4);
%! assert (out, D4);
%! out = bwselect (A, [3 1], [1 3], 8);
%! assert (out, D8);
%! out = bwselect (A, [3 1], [1 3]);
%! assert (out, D8);

%!test
%!error id=Octave:invalid-fun-call bwselect ()
%!error id=Octave:invalid-fun-call bwselect ("aaa")

