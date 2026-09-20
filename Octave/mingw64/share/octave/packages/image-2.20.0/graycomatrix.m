## Copyright (C) 2025 The Octave Project Developers
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
## @deftypefn {Function File} {@var{[glcm, scaled_image]} =} graycomatrix (@var{img})
## @deftypefnx {Function File} {@var{[glcm, scaled_image]} =} graycomatrix (@var{img}, @var{Name}, @var{Value}, @dots{})
##
## Compute the gray-level co-occurrence matrix (GLCM) for an image.
##
## @code{graycomatrix} calculates the GLCM for the input image @var{img}. The GLCM
## is a statistical method of examining the textures that considers the spatial
## relationship of pixels.
##
## @strong{Inputs}
## @table @var
## @item img
## A grayscale image (2D matrix) for which the GLCM is to be computed.
## Image type can be int8, uint8, int16, uint16, int32, uint32, single, double
## or logical.
## @end table
##
## @strong{Name-Value Pair Arguments}
## @table @var
## @item 'Offset'
## An M-by-2 array specifying the pixel pair offsets for which the GLCM is
## calculated. Each row in the array is a two-element integer vector [row_offset, col_offset].
## The default is [0 1], which calculates the GLCM for horizontally adjacent
## pixels.
##
## @item 'NumLevels'
## A scalar specifying the number of gray levels to use when scaling the input
## image. The default is 2 for logical image and 8 for any other image.
## The image is scaled to have integer values between1 and the number of levels.
##
## @item 'GrayLimits'
## A two-element vector [low high] that specifies the intensity values in @var{img}
## that are to be considered when scaling the image to the number of levels.
## The default is the range of the class of @var{img}. if [] is used as input,
## the graylimits are [min(img(:)) max(img(:))].
##
## @item 'Symmetric'
## A logical value indicating whether the GLCM should be symmetric. If true,
## the GLCM is averaged with its transpose to ensure symmetry. The default is
## false.
##
## @item 'use_oct'
## A logical value indicating whether the GLCM computation will use oct file.
## If true the GLCM is computed using cpp code and oct interface.
## If false, the computation is done using Octave function compute_glcm.
## The default is true. The oct computation is a little bit faster,
## and the compute_glcm is left here for educational reasons (Octave only parameter).
##
## @end table
##
## @strong{Outputs}
## @table @var
## @item glcm
## The gray-level co-occurrence matrix or matrices. If multiple offsets are
## specified, @var{glcm} will be a 3D array, where each slice along the third
## dimension corresponds to the GLCM for a particular offset.
##
## @item scaled_image
## Scaled image used to calculate the GLCM (type double).
## @end table
##
## @strong{Example}
## @example
## @group
## img = phantom();
## glcm = graycomatrix (img, 'NumLevels', 16, 'Offset', [0 1; -1 1], 'Symmetric', true);
## @end group
## @end example
##
## @seealso{imhist}
## @end deftypefn


function [glcm, scaled_image] = graycomatrix (img, varargin)

  if (nargin == 0)
    print_usage ();
  elseif (! isimage (img))
    error ("graycomatrix: first argument must be an image")
  elseif (ndims (img) > 2)
    error ("graycomatrix: img should be a 2D image")
  endif

  if (any (isnan (img(:))))
    warning ("Image:Graycomatrix-ignores-nan", "graycomatrix ignores NaN values");
  endif

  # Parse inputs
  params = parse_graycomatrix_inputs (img, varargin{:});

  # Compute scaled image
  scaled_image = compute_scaled_image (img, params);

  # Compute raw GLCM
  if (params.use_oct)
    glcm = __graycomatrix__ (scaled_image - 1, params.offset, ...
                             params.num_levels, params.symmetric);
  else
    glcm = compute_glcm (scaled_image, params);
  endif

endfunction


function params = parse_graycomatrix_inputs (img, varargin)
  # parse_graycomatrix_inputs: Parse and validate input parameters for graycomatrix.
  # Parameters:
  #   img: Input image.
  #   varargin: Name-value pairs.
  # Returns:
  #   params: Struct of parsed parameters.

  #   parse input params
  p = inputParser;
  p.CaseSensitive = false;
  p.FunctionName = "graycomatrix";

  if isa(img, 'logical')
    default_num_levels = 2;
  else
    default_num_levels = 8;
  endif
  # Optional name-value
  addParameter (p, "Offset", [0 1], @ (x) isnumeric (x) && size (x,2) == 2);
  addParameter (p, "NumLevels", default_num_levels, ...
                    @ (x) isnumeric (x) && isscalar (x) && x >= 1);
  addParameter (p, "GrayLimits", double (getrangefromclass (img)),
                    @ (x) isempty (x) || (isnumeric (x) && numel (x)==2));
  addParameter (p, "Symmetric", false, @ (x) islogical (x));
  addParameter (p, "use_oct", true, @ (x) islogical (x));

  parse (p, varargin{:});
  results = p.Results;

  # GrayLimits default
  if isempty (results.GrayLimits)
    gray_limits = double ([min(img(:)) max(img(:))]);
  else
    gray_limits = double (results.GrayLimits(:)');
  end

  # Pack params
  params.offset        = double (results.Offset);
  params.num_levels    = double (results.NumLevels);
  params.gray_limits   = gray_limits;
  params.symmetric     = logical (results.Symmetric);
  params.use_oct       = logical (results.use_oct);

endfunction


function scaled_image = compute_scaled_image (img, params)
  # compute_scaled_image: Scale image to integer levels for GLCM computation.
  # Parameters:
  #   img: Input image.
  #   params: Struct of parameters.
  # Returns:
  #   scaled_image: Scaled image (type double).

  img        = double (img);
  num_levels  = params.num_levels;
  gray_limits = params.gray_limits;


  scaled_image = nan (size(img)); # Initialize with NaN

  valid_mask = ! isnan (img);

  # Clip and scale image to [1..numLevels]

  if (gray_limits (1) == gray_limits (2))
    scaled_image(valid_mask) = 1;
  else
    scaled_image(valid_mask) = floor ((img(valid_mask) - gray_limits(1)) / ...
                               (gray_limits(2) - gray_limits(1)) * num_levels + 1);
    scaled_image(scaled_image < 1 & valid_mask) = 1;
    scaled_image(scaled_image > num_levels & valid_mask) = num_levels;
  endif

endfunction


function glcm = compute_glcm (scaled_image, params)
  # compute_glcm: Compute gray-level co-occurrence matrix (GLCM) for scaled image.
  # Parameters:
  #   scaled_image: Scaled image (type double).
  #   params: Struct of parameters.
  # Returns:
  #   glcm: GLCM matrix or matrices.

  # Mask out pairs with NaN in both ref and neighbor
  # Only valid pairs are counted in GLCM

  # compute glcm matrix
  num_levels  = params.num_levels;
  offset      = params.offset;
  symmetric   = params.symmetric;

  n_offsets = size (offset, 1);
  glcm = zeros (num_levels, num_levels, n_offsets);

  [rows, cols] = size (scaled_image);
  num_levels2 = num_levels * num_levels;

  for k = 1:n_offsets
    dy = offset(k, 1);
    dx = offset(k, 2);

    # valid pixel ranges
    r1 = max (1, 1 - dy) : min (rows, rows - dy);
    c1 = max (1, 1 - dx) : min (cols, cols - dx);
    r2 = r1 + dy;
    c2 = c1 + dx;

    ref      = scaled_image(r1, c1);
    neighbor = scaled_image(r2, c2);

    # Mask out pairs with NaN
    valid_mask = !isnan(ref) & !isnan(neighbor);
    ref_valid = ref(valid_mask);
    neighbor_valid = neighbor(valid_mask);

    lin_ind   = sub2ind ([num_levels, num_levels], ref_valid(:), neighbor_valid(:));

    # count occurrences
    counts = accumarray (lin_ind, 1, [num_levels2, 1]);
    gl = reshape (counts, num_levels, num_levels);

    if (symmetric)
      gl = gl + gl';
    endif

    glcm(:, :, k) = gl;
  endfor
endfunction


%!test
%! # Test basic functionality with default parameters
%! img = [1 1 5 6; 3 5 7 1; 5 6 7 8; 8 1 5 1];
%! img = double(img) / 8;
%! [glcm, scaled_image] = graycomatrix (img);
%! expected_si = [2 2 6 7; 4 6 8 2; 6 7 8 8; 8 2 6 2];
%! expected_glcm = zeros (8, 8);
%! expected_glcm(2, 2) = 1; expected_glcm(2, 6) = 2; expected_glcm(4,6) = 1;
%! expected_glcm(6, 2) = 1; expected_glcm(6, 7) = 2; expected_glcm(6, 8) = 1;
%! expected_glcm(7, 8) = 1; expected_glcm(8, 2) = 2; expected_glcm(8, 8) = 1;
%! assert (isequal (scaled_image, expected_si));
%! assert (isequal (glcm, expected_glcm));

%!test
%! # Test with NumLevels parameter
%! img = [1 2; 3 4];
%! [glcm, scaled_image] = graycomatrix (img, "NumLevels", 4);
%! expected_si = 4*ones (2, 2);
%! expected_glcm = zeros (4, 4);
%! expected_glcm(4,4) = 2;
%! assert (isequal (scaled_image, expected_si));
%! assert (isequal (glcm, expected_glcm));

%!test
%! # Test with GrayLimits parameter
%! img = [0 0.2; 0.6 1.0];
%! [glcm, scaled_image] = graycomatrix (img, "GrayLimits", [0 1], "NumLevels", 4);
%! expected_si = [1 1; 3 4];
%! expected_glcm = zeros (4, 4);
%! expected_glcm(1,1) = 1; expected_glcm(3,4) = 1;
%! assert (isequal (scaled_image, expected_si));
%! assert (isequal (glcm, expected_glcm));

%!test
%! # Test with Offset parameter - horizontal right [0 1]
%! img = [1 2 3; 4 5 6; 7 8 9];
%! [glcm, scaled_image] = graycomatrix (img, "NumLevels", 9);
%! expected_glcm = zeros (9, 9);
%! expected_glcm(9,9) = 6;
%! assert (isequal (glcm, expected_glcm));

%!test
%! # Test with Offset parameter - vertical down [1 0]
%! img = [1 2 3; 4 5 6; 7 8 9];
%! [glcm, scaled_image] = graycomatrix (img, "NumLevels", 9, "Offset", [1 0], "GrayLimits", []);
%! expected_glcm = zeros (9, 9);
%! expected_glcm(1,4) = 1; expected_glcm(2,5) = 1; expected_glcm(3,6) = 1;
%! expected_glcm(4,7) = 1; expected_glcm(5,8) = 1; expected_glcm(6,9) = 1;
%! assert (isequal (glcm, expected_glcm));

%!test
%! # Test with Offset parameter - vertical down [1 0]
%! img = [1 2 3; 4 5 6; 7 8 9];
%! [glcm, scaled_image] = graycomatrix (img, "NumLevels", 9, "Offset", [1 0]);
%! expected_glcm = zeros (9, 9);
%! expected_glcm(9,9) = 6;
%! assert (isequal (glcm, expected_glcm));

%!test
%! # Test with Offset parameter - vertical down [1 0]
%! img = [1 2 3; 4 5 6; 7 8 9];
%! [glcm, scaled_image] = graycomatrix (img, "NumLevels", 9, "Offset", [1 0], "GrayLimits", []);
%! expected_glcm = zeros (9, 9);
%! expected_glcm(1,4) = 1; expected_glcm(2,5) = 1; expected_glcm(3,6) = 1;
%! expected_glcm(4,7) = 1; expected_glcm(5,8) = 1; expected_glcm(6,9) = 1;
%! assert (isequal (glcm, expected_glcm));

%!test
%! # Test with multiple offsets
%! img = [1 2; 3 4];
%! [glcm, scaled_image] = graycomatrix (img, "NumLevels", 4, "Offset", [0 1; 1 0], "GrayLimits", []);
%! expected_glcm1 = zeros (4, 4);
%! expected_glcm1(1, 2) = 1; expected_glcm1(3, 4) = 1;
%! expected_glcm2 = zeros (4, 4);
%! expected_glcm2(1, 3) = 1; expected_glcm2(2, 4) = 1;
%! assert (isequal (glcm(:, :, 1), expected_glcm1));
%! assert (isequal (glcm(:, :, 2), expected_glcm2));

%!test
%! # Test with Symmetric parameter
%! img = [1 2; 3 4];
%! [glcm, scaled_image] = graycomatrix (img, "NumLevels", 4, "GrayLimits", [], "Symmetric", true);
%! expected_glcm = zeros (4, 4);
%! expected_glcm(1,2) = 1; expected_glcm(2,1) = 1;
%! expected_glcm(3,4) = 1; expected_glcm(4,3) = 1;
%! assert (isequal (glcm, expected_glcm));

%!test
%! # Test with constant image
%! img = ones (3, 3);
%! [glcm, scaled_image] = graycomatrix (img, "NumLevels", 8);
%! expected_glcm = zeros (8, 8);
%! expected_glcm(8, 8) = 6;  # 6 horizontal neighbor pairs all with value 1
%! assert (isequal (glcm, expected_glcm));

%!test
%! # Test with edge cases - check if offset goes outside image bounds
%! img = [1 2; 3 4];
%! [glcm, scaled_image] = graycomatrix (img, "NumLevels", 4, "Offset", [2 2]);
%! expected_glcm = zeros (4, 4);  # Should be empty as all pairs are outside bounds
%! assert (isequal (glcm, expected_glcm));

%!test
%! # Test with edge cases - equal GrayLimits
%! img = [1 2; 3 4];
%! [glcm, scaled_image] = graycomatrix (img, "GrayLimits", [2 2]);
%! expected_si = ones (2, 2);  # All pixels should be mapped to 1
%! expected_glcm = zeros (8, 8);
%! expected_glcm(1,1) = 2;  # 2 horizontal neighbor pairs all with value 1
%! assert (isequal (scaled_image, expected_si));
%! assert (isequal (glcm, expected_glcm));

%!test
%! # Test with negative offsets
%! img = [1 2; 3 4];
%! [glcm, scaled_image] = graycomatrix (img, "NumLevels", 4, "Offset", [-1 0], "GrayLimits", []);
%! # This is equivalent to offset [1 0] but in the opposite direction
%! expected_glcm = zeros (4, 4);
%! expected_glcm(3,1) = 1; expected_glcm(4,2) = 1;
%! assert (isequal (glcm, expected_glcm));

%!test
%! # Test with diagonal offset
%! img = [1 2 3; 4 5 6; 7 8 9];
%! [glcm, scaled_image] = graycomatrix (img, "NumLevels", 9, "Offset", [1 1], "GrayLimits", []);
%! expected_glcm = zeros (9, 9);
%! expected_glcm(1,5) = 1; expected_glcm(2,6) = 1;
%! expected_glcm(4,8) = 1; expected_glcm(5,9) = 1;
%! assert (isequal (glcm, expected_glcm));

%!test
%! # Test with phantom input
%! img = phantom();
%! glcm = graycomatrix (img, "NumLevels", 5);
%! expected_glcm = [58979     105       0       0     457;
%!                   105    2788       0       0       0;
%!                     0       0       0       0       0;
%!                     0       0       0       0       0;
%!                   457       0       0       0    2389];
%! assert (isequal (glcm, expected_glcm));

%!test
%! # Test with phantom input
%! img = phantom();
%! glcm = graycomatrix (img, "NumLevels", 5, "Symmetric", true);
%! expected_glcm = [58979     105       0       0     457;
%!                   105    2788       0       0       0;
%!                     0       0       0       0       0;
%!                     0       0       0       0       0;
%!                   457       0       0       0    2389];
%! assert (isequal (glcm, expected_glcm  + expected_glcm'));

%!test
%! # Test with phantom input
%! img = phantom();
%! glcm = graycomatrix (img, "NumLevels", 5, "GrayLimits", []);
%! expected_glcm = [37552    176       0       0     234;
%!                   176   24015       6       0     223;
%!                     0       6      46       0       0;
%!                     0       0       0       0       0;
%!                   234     223       0       0    2389];
%! assert (isequal (glcm, expected_glcm));

%!test
%! # Test use_oct
%! img = phantom();
%! glcm1 = graycomatrix (img, "use_oct", true);
%! glcm2 = graycomatrix (img, "use_oct", false);
%! assert (isequal (glcm1, glcm2));

%!test
%! # Test use_oct
%! img = phantom();
%! glcm1 = graycomatrix (img, "NumLevels", 5, "GrayLimits", []);
%! glcm2 = graycomatrix (img, "NumLevels", 5, "GrayLimits", [], "use_oct", true);
%! assert (isequal (glcm1, glcm2));

%!test
%! # Test use_oct
%! img = phantom();
%! glcm1 = graycomatrix (img, "NumLevels", 5, "GrayLimits", [], "use_oct", true);
%! glcm2 = graycomatrix (img, "NumLevels", 5, "GrayLimits", [], "use_oct", false);
%! assert (isequal (glcm1, glcm2));

%!test
%! # Test with phantom input
%! img = phantom();
%! glcm1 = graycomatrix (img, "use_oct", true);
%! glcm2 = graycomatrix (img, "use_oct", false);
%! assert (isequal (glcm1, glcm2));

%!test
%! # test with different image types
%!
%! # uint8
%! expected_glcm = zeros (8);
%! expected_glcm(1:4, 1:4) = [ 15,  7,  7, 1; ...
%!                              3, 16,  7, 0; ...
%!                              6,  9, 11, 3; ...
%!                              2,  0,  3, 0];
%! assert (isequal (graycomatrix (uint8(magic(10))), expected_glcm));
%!
%! # uint16
%! expected_glcm = zeros (8);
%! expected_glcm(1, 1) = 90;
%! assert (isequal (graycomatrix (uint16(magic(10))), expected_glcm));
%!
%! # uint32
%! assert (isequal (graycomatrix (uint32(magic(10))), expected_glcm));
%!
%! # int8
%! expected_glcm = zeros (8);
%! expected_glcm(5:8, 5:8) = [ 15,  7,  7, 1; ...
%!                              3, 16,  7, 0; ...
%!                              6,  9, 11, 3; ...
%!                              2,  0,  3, 0];
%! assert (isequal (graycomatrix (int8(magic(10))), expected_glcm));
%!
%! # int16
%! expected_glcm = zeros (8);
%! expected_glcm(5, 5) = 90;
%! assert (isequal (graycomatrix (int16(magic(10))), expected_glcm));
%!
%! # int32
%! assert (isequal (graycomatrix (int32(magic(10))), expected_glcm));
%!
%! # single
%! expected_glcm = zeros (8);
%! expected_glcm(8, 8) = 90;
%! assert (isequal (graycomatrix (single(magic(10))), expected_glcm));
%
%! # double
%! assert (isequal (graycomatrix (double(magic(10))), expected_glcm));

%! # logical
%! assert (isequal (graycomatrix (magic(10) > 50), [29, 16; 16, 29]));

%!test
%! # bug #67905
%!
%! # Save current warning state
%! state = warning;
%! warning ("off", "Image:Graycomatrix-ignores-nan");
%! img = [1:5; 6:10]; img(end) = nan;
%! [glcm, SI] = graycomatrix (img);
%! glcm_exp = zeros (8); glcm_exp(8, 8) = 7;
%! SI_exp = 8 * ones (2, 5); SI_exp(2, 5) = NaN;
%! assert (isequal (glcm, glcm_exp))
%! assert (isequaln (SI, SI_exp))
%! [glcm, SI] = graycomatrix (img, 'use_oct', true);
%! assert (isequal (glcm, glcm_exp))
%! assert (isequaln (SI, SI_exp))
%! [glcm, SI] = graycomatrix (img, 'use_oct', false);
%! assert (isequal (glcm, glcm_exp))
%! assert (isequaln (SI, SI_exp))
%! # Restore the original warning state
%! warning (state);


%!error <Invalid call to graycomatrix> graycomatrix ()
%!error <graycomatrix: first argument must be an image> graycomatrix ("xxx")
%!error <graycomatrix: first argument must be an image> graycomatrix ([])
%!error graycomatrix (1, 2)
%!error <graycomatrix: img should be a 2D image> graycomatrix (cat(3, [1 2], [1 2], [1 2]))
%!error <graycomatrix: argument 'AAA' is not a > graycomatrix ([1, 2], "AAA")
%!error <graycomatrix: failed validation of> graycomatrix (phantom(), "GrayLimits", 0)
%!error <graycomatrix: failed validation of> graycomatrix (phantom(), "GrayLimits", "aa")
%!error <graycomatrix: failed validation of> graycomatrix (phantom(), "NumLevels", "0")
%!error <graycomatrix: failed validation of> graycomatrix (phantom(), "Symmetric", 1);
%!error <graycomatrix: failed validation of> graycomatrix (phantom(), "Offset", 1);
%!error <graycomatrix: failed validation of> graycomatrix (phantom(), "Offset", [1, 2]');
%!error <graycomatrix: failed validation of> graycomatrix (phantom(), "Offset", true);
%!error <graycomatrix: failed validation of> graycomatrix (phantom(), "Offset", [[1 2 3 4]]);

%!demo
%! % Demonstration of graycomatrix with phantom image
%! disp("Demonstrating graycomatrix with the Shepp-Logan phantom:");
%! P = phantom(50);
%! figure(1); imagesc(P); colormap(gray); title("Phantom Image");
%! colorbar; axis image;
%!
%! % Calculate GLCMs with different parameters
%! [glcm1, SI] = graycomatrix (P, "NumLevels", 8, "Offset", [0 1]);
%! [glcm2, ~] = graycomatrix (P, "NumLevels", 8, "Offset", [1 0]);
%! [glcm3, ~] = graycomatrix (P, "NumLevels", 8, "Offset", [1 1]);
%! [glcm4, ~] = graycomatrix (P, "NumLevels", 8, "Offset", [0 1], "Symmetric", true);
%!
%! % Display the scaled image and GLCMs
%! figure(2); imagesc(SI); colormap(gray); title("Scaled Image (8 levels)");
%! colorbar; axis image;
%!
%! figure(3);
%! subplot(2,2,1); imagesc(log2(glcm1+1)); title("log2 GLCM [0 1]"); colorbar;
%! subplot(2,2,2); imagesc(log2(glcm2+1)); title("log2 GLCM [1 0]"); colorbar;
%! subplot(2,2,3); imagesc(log2(glcm3+1)); title("log2 GLCM [1 1]"); colorbar;
%! subplot(2,2,4); imagesc(log2(glcm4+1)); title("log2 GLCM [0 1] Symmetric"); colorbar;
%!
%! % Calculate and display GLCMs with different number of levels
%! figure(4);
%! levels = [4, 8, 16, 32];
%! for i = 1:length(levels)
%!   [glcm, ~] = graycomatrix (P, "NumLevels", levels(i));
%!   subplot(2,2,i);
%!   imagesc(glcm);
%!   title(sprintf("GLCM with %d levels", levels(i)));
%!   colorbar;
%! end
%!
%! disp("The figures show how different parameters affect the GLCM computation.");
%! disp("Figure 1: Original phantom image");
%! disp("Figure 2: Scaled image with 8 gray levels");
%! disp("Figure 3: GLCMs with different offsets and symmetry");
%! disp("Figure 4: GLCMs with different numbers of gray levels");
