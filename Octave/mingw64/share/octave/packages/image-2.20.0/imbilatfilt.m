## Copyright (C) 2025 The Octave Project Developers
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
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
##
## @deftypefn {Function File} {@var{J} =} imbilatfilt (@var{I})
## @deftypefnx {Function File} {@var{J} =} imbilatfilt (@var{I}, @var{degree_of_smoothing})
## @deftypefnx {Function File} {@var{J} =} imbilatfilt (@var{I}, @var{DegreeOfSmoothing}, @var{spatial_sigma})
## @deftypefnx {Function File} {@var{J} =} imbilatfilt (@var{I}, Name, Value, @dots{})
##
## Performs edge-preserving bilateral filtering on an image.
##
## @strong{Algorithm}:
## Bilateral filtering as described in Tomasi & Manduchi, "Bilateral Filtering for Gray and Color Images", ICCV 1998.
## The underlying implementation is in the internal function __bilateral__.
##
## @strong{Inputs}:
##  @itemize
##    @item @var{I}: Input grayscale or RGB image (uint8, int8, uint16, int16, uint32, int32, single, or double).
##    @item @var{degree_of_smoothing}: Range Gaussian variance (default: 0.01 * dynamic range squared).
##    @item @var{spatial_sigma}: Spatial Gaussian standard deviation (default: 1).
##  @end itemize
##
##    Note that for the range Gaussian, the variance is given, and for spatial Gaussian, standard deviation is given.
##
## @strong{Name-Value Pair Arguments}:
##  @itemize
##    @item @qcode{"NeighborhoodSize"}: Window size (odd scalar). Default: @qcode{2 * ceil (2 * spatial_sigma) + 1}.
##    @item @qcode{"Padding"}: Border handling. Options:
##      @itemize
##        @item @qcode{"replicate"} (default)
##        @item @qcode{"symmetric"}
##        @item @qcode{"circular"}
##        @item constant scalar value
##      @end itemize
##  @end itemize
##
## @strong{Output}:
##  @itemize
##    @item @var{J}: Filtered image, same size and class as @var{I}.
##  @end itemize
##
## @seealso{imgaussfilt}
## @end deftypefn

function img_out = imbilatfilt (img, varargin)

  if (nargin == 0)
    print_usage ();
  elseif (! isimage (img))
    error ("imbilatfilt: first argument must be an image")
  endif

  # Parse inputs
  param = parse_imbilatfilt_inputs (img, varargin{:});

  s = floor (param.neighborhood_size / 2);
  img_pad = padarray (img, [s, s], param.padding);

  img_out = __bilateral__ (img_pad, param.spatial_sigma, ...
                            sqrt(param.degree_of_smoothing), s);

  cls = class (img);
  if ! strcmp(class (img_out), cls)
    img_out = imcast (img_out, cls);
  endif

endfunction

function param = parse_imbilatfilt_inputs (I, varargin)

  default_degree_of_smoothing = 0.01 * diff (getrangefromclass (I)) .^ 2;
  default_spatial_sigma = 1;
  default_neighborhood_size = 2 * ceil (2 * default_spatial_sigma) + 1;
  default_padding = "replicate";

  param = struct (...
  "degree_of_smoothing", default_degree_of_smoothing, ...
  "spatial_sigma", default_spatial_sigma, ...
  "neighborhood_size", default_neighborhood_size, ...
  "padding", default_padding);

  if (isempty (varargin))
      if (param.neighborhood_size >= size(I, 1) || param.neighborhood_size >= size(I, 2))
          error("imbilatfilt: image size must be greater than neighborhood_size (##d)", ...
                param.neighborhood_size);
      endif
    return
  endif

  istart = 1;
  if (! ischar (varargin{1}))
    param.degree_of_smoothing = varargin{1};
    validate_degree_of_smoothing (param.degree_of_smoothing);
    istart = 2;
    if (length(varargin) > 1 && ! ischar (varargin{2}))
        param.spatial_sigma = varargin{2};
        validate_spatial_sigma (param.spatial_sigma);
        default_neighborhood_size = 2 * ceil (2 * param.spatial_sigma) + 1;
        istart = 3;
    endif
  endif

  p = inputParser;
  p.CaseSensitive = false;
  p.FunctionName = "imbilatfilt";

  addParameter (p, "NeighborhoodSize", default_neighborhood_size, ...
                @(x) validateattributes(x, {"numeric"}, ...
                {"nonempty", "positive", "scalar", "odd", "integer", ...
                 ">=", 1, "<", size(I, 1), "<", size(I, 2)}));
  addParameter (p, "Padding", default_padding);  ## validated below

  parse (p, varargin{istart : end});
  res = p.Results;

  param.neighborhood_size = res.NeighborhoodSize;
  # another validating of NeighborhoodSize
  if (param.neighborhood_size >= size (I, 1) || param.neighborhood_size >= size (I, 2))
      error("imbilatfilt: image size must be greater than neighborhood_size (##d)", ...
            param.neighborhood_size);
  endif

  # Validate Padding
  if ischar (res.Padding) || isstring (res.Padding)
    param.padding = validatestring (res.Padding, {"replicate", ...
    "symmetric", "circular"});
  elseif (isnumeric (res.Padding) && isscalar (res.Padding))
      param.padding = res.Padding;
  else
    error("imbilatfilt: Padding must be a string or numeric scalar");
  endif

endfunction

function validate_degree_of_smoothing (x)
  validateattributes (x, {"numeric"}, {"scalar", "positive"}, ...
      "imbilatfilt", "degree_of_smoothing");
endfunction

function validate_spatial_sigma (x)
  validateattributes (x, {"numeric"}, {"scalar", "positive"}, ...
      "imbilatfilt", "spatial_sigma");
endfunction

%!test
%!error <Invalid call to imbilatfilt> imbilatfilt ();
%!error <imbilatfilt: first argument must be an image> imbilatfilt ("aaa");
%!error <imbilatfilt: first argument must be an image> imbilatfilt ({});
%!error <imbilatfilt: image size must be greater than neighborhood_size> imbilatfilt (1);
%!error <imbilatfilt: degree_of_smoothing must be positive> imbilatfilt (eye(5), -1);
%!error <imbilatfilt: degree_of_smoothing must be scalar> imbilatfilt (eye(5), [1 1]);
%!error <imbilatfilt: image size must be greater than neighborhood_size> imbilatfilt (eye(5), 1);
%!error <imbilatfilt: spatial_sigma must be positive> imbilatfilt (eye(9), 1, -1);
%!error <imbilatfilt: spatial_sigma must be scalar> imbilatfilt (eye(9), 1, [1, 1]);
%!error <imbilatfilt: argument 'AAA' is not a> imbilatfilt (eye(9), "AAA");
%!error <imbilatfilt: argument 'AAA' is not a> imbilatfilt (eye(9), 1, "AAA");
%!error <imbilatfilt: argument 'AAA' is not a> imbilatfilt (eye(9), 1, 1, "AAA");
%!error imbilatfilt (eye(9), 1, 1, "padding");
%!error <validatestring: 'aa' does not match any of> imbilatfilt (eye(9), 1, 1, "padding", "aa");
%!error <imbilatfilt: Padding must be a string or numeric scalar> imbilatfilt (eye(9), 1, 1, 'padding', [1 1]);
%!error imbilatfilt (eye(9), 1, 1, "NeighborhoodSize");
%!error imbilatfilt (eye(9), 1, 1, "NeighborhoodSize", 2);
%!error imbilatfilt (eye(9), 1, 1, "NeighborhoodSize", [3, 3]);

%!test
%! out = imbilatfilt (eye (6));
%! expected = [1.0000  0.0000  0.0000  0.0000  0.0000  0.0000
%!             0.0000  1.0000  0.0000  0.0000  0.0000  0.0000
%!             0.0000  0.0000  1.0000  0.0000  0.0000  0.0000
%!             0.0000  0.0000  0.0000  1.0000  0.0000  0.0000
%!             0.0000  0.0000  0.0000  0.0000  1.0000  0.0000
%!             0.0000  0.0000  0.0000  0.0000  0.0000  1.0000];
%! assert(out, expected, 1e-4);
%!test
%! out = imbilatfilt (eye (6), 1);
%! expected = [0.6723  0.2229  0.0762  0.0163  0.0018  0.0000
%!             0.2229  0.4300  0.1506  0.0654  0.0163  0.0018
%!             0.0762  0.1506  0.3993  0.1485  0.0654  0.0163
%!             0.0163  0.0654  0.1485  0.3993  0.1506  0.0762
%!             0.0018  0.0163  0.0654  0.1506  0.4300  0.2229
%!             0.0000  0.0018  0.0163  0.0762  0.2229  0.6723];
%! assert(out, expected, 1e-4);
%!test
%! out = imbilatfilt (eye (6), 2);
%! expected = [0.6151  0.2692  0.0958  0.0208  0.0023  0.0000
%!             0.2692  0.3701  0.1855  0.0825  0.0208  0.0023
%!             0.0958  0.1855  0.3411  0.1829  0.0825  0.0208
%!             0.0208  0.0825  0.1829  0.3411  0.1855  0.0958
%!             0.0023  0.0208  0.0825  0.1855  0.3701  0.2692
%!             0.0000  0.0023  0.0208  0.0958  0.2692  0.6151];
%! assert(out, expected, 1e-4);
%!test
%! out = imbilatfilt (eye (6), 3, 0.1, "NeighborhoodSize", 3);
%! expected = [1.0000  0.0000  0.0000  0.0000  0.0000  0.0000
%!             0.0000  1.0000  0.0000  0.0000  0.0000  0.0000
%!             0.0000  0.0000  1.0000  0.0000  0.0000  0.0000
%!             0.0000  0.0000  0.0000  1.0000  0.0000  0.0000
%!             0.0000  0.0000  0.0000  0.0000  1.0000  0.0000
%!             0.0000  0.0000  0.0000  0.0000  0.0000  1.0000];
%! assert(out, expected, 1e-4);
%!test
%! out = imbilatfilt (eye (6), 3, 0.5, "NeighborhoodSize", 3);
%! expected = [0.8340  0.1558  0.0096  0.0000  0.0000  0.0000
%!             0.1558  0.6794  0.1457  0.0096  0.0000  0.0000
%!             0.0096  0.1457  0.6794  0.1457  0.0096  0.0000
%!             0.0000  0.0096  0.1457  0.6794  0.1457  0.0096
%!             0.0000  0.0000  0.0096  0.1457  0.6794  0.1558
%!             0.0000  0.0000  0.0000  0.0096  0.1558  0.8340];
%! assert(out, expected, 1e-4);
%!test
%! out = imbilatfilt (eye (6), 3, 1, "NeighborhoodSize", 3);
%! expected = [0.6413  0.2875  0.0643  0.0000  0.0000  0.0000
%!             0.2875  0.3934  0.2179  0.0643  0.0000  0.0000
%!             0.0643  0.2179  0.3934  0.2179  0.0643  0.0000
%!             0.0000  0.0643  0.2179  0.3934  0.2179  0.0643
%!             0.0000  0.0000  0.0643  0.2179  0.3934  0.2875
%!             0.0000  0.0000  0.0000  0.0643  0.2875  0.6413];
%! assert(out, expected, 1e-4);
%!test
%! out = imbilatfilt (eye (6), 3, 10, "NeighborhoodSize", 3);
%! expected = [0.5966  0.2974  0.0954  0.0000  0.0000  0.0000
%!             0.2974  0.3713  0.1951  0.0954  0.0000  0.0000
%!             0.0954  0.1951  0.3713  0.1951  0.0954  0.0000
%!             0.0000  0.0954  0.1951  0.3713  0.1951  0.0954
%!             0.0000  0.0000  0.0954  0.1951  0.3713  0.2974
%!             0.0000  0.0000  0.0000  0.0954  0.2974  0.5966];
%! assert(out, expected, 1e-4);
%!test
%! out = imbilatfilt (eye (6), 3, 10, "NeighborhoodSize", 3, "padding", 0);
%! expected = [0.2528  0.1951  0.0954  0.0000  0.0000  0.0000
%!             0.1951  0.3713  0.1951  0.0954  0.0000  0.0000
%!             0.0954  0.1951  0.3713  0.1951  0.0954  0.0000
%!             0.0000  0.0954  0.1951  0.3713  0.1951  0.0954
%!             0.0000  0.0000  0.0954  0.1951  0.3713  0.1951
%!             0.0000  0.0000  0.0000  0.0954  0.1951  0.2528];
%! assert(out, expected, 1e-4);
%!test
%! out = imbilatfilt (eye (6), 3, 1, "NeighborhoodSize", 3, "padding", 0);
%! expected = [0.3140  0.2179  0.0643  0.0000  0.0000  0.0000
%!             0.2179  0.3934  0.2179  0.0643  0.0000  0.0000
%!             0.0643  0.2179  0.3934  0.2179  0.0643  0.0000
%!             0.0000  0.0643  0.2179  0.3934  0.2179  0.0643
%!             0.0000  0.0000  0.0643  0.2179  0.3934  0.2179
%!             0.0000  0.0000  0.0000  0.0643  0.2179  0.3140];
%! assert(out, expected, 1e-4);
%!test
%! out = imbilatfilt (eye (6), 3, 1, "NeighborhoodSize", 3, "padding", "r");
%! expected = [0.6413  0.2875  0.0643  0.0000  0.0000  0.0000
%!             0.2875  0.3934  0.2179  0.0643  0.0000  0.0000
%!             0.0643  0.2179  0.3934  0.2179  0.0643  0.0000
%!             0.0000  0.0643  0.2179  0.3934  0.2179  0.0643
%!             0.0000  0.0000  0.0643  0.2179  0.3934  0.2875
%!             0.0000  0.0000  0.0000  0.0643  0.2875  0.6413];
%! assert(out, expected, 1e-4);
%!test
%! out = imbilatfilt (eye (6), 3, 1, "NeighborhoodSize", 3, "padding", "s");
%! expected = [0.6413  0.2875  0.0643  0.0000  0.0000  0.0000
%!             0.2875  0.3934  0.2179  0.0643  0.0000  0.0000
%!             0.0643  0.2179  0.3934  0.2179  0.0643  0.0000
%!             0.0000  0.0643  0.2179  0.3934  0.2179  0.0643
%!             0.0000  0.0000  0.0643  0.2179  0.3934  0.2875
%!             0.0000  0.0000  0.0000  0.0643  0.2875  0.6413];
%! assert(out, expected, 1e-4);
%!test
%! out = imbilatfilt (single (eye (6)), 1);
%! expected = [0.6723  0.2229  0.0762  0.0163  0.0018  0.0000
%!             0.2229  0.4300  0.1506  0.0654  0.0163  0.0018
%!             0.0762  0.1506  0.3993  0.1485  0.0654  0.0163
%!             0.0163  0.0654  0.1485  0.3993  0.1506  0.0762
%!             0.0018  0.0163  0.0654  0.1506  0.4300  0.2229
%!             0.0000  0.0018  0.0163  0.0762  0.2229  0.6723];
%! assert(out, single (expected), 1e-4);
%!test
%! out = imbilatfilt (uint8 (150 * eye (8)), 200000, 1.5);
%! expected = [ 72   46   26   12    4    1    0    0
%!              46   42   29   18   10    4    1    0
%!              26   29   32   25   18   10    4    1
%!              12   18   25   31   25   18   10    4
%!               4   10   18   25   31   25   18   12
%!               1    4   10   18   25   32   29   26
%!               0    1    4   10   18   29   42   46
%!               0    0    1    4   12   26   46   72];
%! assert(out, uint8 (expected));
%! out = imbilatfilt (int8 (150 * eye (8)), 200000, 1.5);
%! expected = [ ...
%!   60  39  22  10   3   1   0   0;
%!   39  35  25  16   8   3   1   0;
%!   22  25  27  22  15   8   3   1;
%!   10  16  22  26  21  15   8   3;
%!    3   8  15  21  26  22  16  10;
%!    1   3   8  15  22  27  25  22;
%!    0   1   3   8  16  25  35  39;
%!    0   0   1   3  10  22  39  60];
%! assert(out, int8 (expected));
%!
%!test
%! out = imbilatfilt (uint16 (1500 * eye (8)), 200000, 1.5);
%! expected = [1494    3    1    0    0    0    0    0
%!               3  1485    1    1    0    0    0    0
%!               1    1  1479    1    1    0    0    0
%!               0    1    1  1478    1    1    0    0
%!               0    0    1    1  1478    1    1    0
%!               0    0    0    1    1  1479    1    1
%!               0    0    0    0    1    1  1485    3
%!               0    0    0    0    0    1    3  1494];
%! assert(out, uint16 (expected));
%!test
%! out = imbilatfilt (int16 (1500 * eye (8)), 200000, 1.5);
%! expected = [1494    3    1    0    0    0    0    0
%!               3  1485    1    1    0    0    0    0
%!               1    1  1479    1    1    0    0    0
%!               0    1    1  1478    1    1    0    0
%!               0    0    1    1  1478    1    1    0
%!               0    0    0    1    1  1479    1    1
%!               0    0    0    0    1    1  1485    3
%!               0    0    0    0    0    1    3  1494];
%! assert(out, int16 (expected));
%!test
%! out = imbilatfilt (int32 (1500 * eye (8)), 200000, 1.5);
%! expected = [1494    3    1    0    0    0    0    0
%!               3  1485    1    1    0    0    0    0
%!               1    1  1479    1    1    0    0    0
%!               0    1    1  1478    1    1    0    0
%!               0    0    1    1  1478    1    1    0
%!               0    0    0    1    1  1479    1    1
%!               0    0    0    0    1    1  1485    3
%!               0    0    0    0    0    1    3  1494];
%! assert(out, int32 (expected));
%!test
%! out = imbilatfilt (uint32 (1500 * eye (8)), 200000, 1.5);
%! expected = [1494    3    1    0    0    0    0    0
%!               3  1485    1    1    0    0    0    0
%!               1    1  1479    1    1    0    0    0
%!               0    1    1  1478    1    1    0    0
%!               0    0    1    1  1478    1    1    0
%!               0    0    0    1    1  1479    1    1
%!               0    0    0    0    1    1  1485    3
%!               0    0    0    0    0    1    3  1494];
%! assert(out, uint32 (expected));
%!
%!test
%! img = uint8(cat(3, magic(10), imrotate(magic(10), 90), imrotate(magic(10), 180)));
%! assert(squeeze(max(max(abs(double(img) - double(imbilatfilt(img)))))), [11, 11, 10]');
