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
## @deftypefn {Function File} {@var{BW} =} imbinarize (@var{I})
## @deftypefnx {Function File} {@var{BW} =} imbinarize (@var{I}, @var{threshold})
## @deftypefnx {Function File} {@var{BW} =} imbinarize (@var{I}, @var{method})
## @deftypefnx {Function File} {@var{BW} =} imbinarize (@dots{}, @var{name}, @var{value}, @dots{})
## @cindex imbinarize
##
## Convert an image to a binary image using a specified thresholding method.
##
## @strong{Inputs}
## @itemize @bullet
## @item
## @var{I} -- The input image, which is a grayscale image.
## Image type can be int8, uint8, int16, uint16, int32, uint32, single or double.
## imbinarize currently supports RGB images with "global" option (see below)
## but only 2D grayscale image inputs with option "adaptive"
##
## @item
## @var{method} -- A string specifying the thresholding method.
## Possible values are "global" (default) or "adaptive" (optional).
## @item
## @var{threshold} -- (Optional) A scalar value representing the global threshold,
## or a matrix in the size of the image that presents the local threshold.
## If not specified, the threshold is calculated according to the method.
## @item
## @var{sensitivity} -- (Optional, used with "adaptive") A scalar value in the range [0, 1]
## that specifies the sensitivity for adaptive thresholding.
## Higher values result in more sensitive thresholding. Default is 0.5.
## @item
## @var{foregroundPolarity} -- (Optional, used with "adaptive") A string specifying the polarity of the foreground.
## Possible values are "bright" (default) or "dark". This determines which pixel values are considered
## foreground.
## @end itemize
##
## @strong{Outputs}
## @itemize @bullet
## @item
## @var{BW} -- The resulting binary image. It is a logical array where pixels with values greater
## than the threshold are set to 1 (true) and others to 0 (false). For "adaptive" mode,
## it uses local thresholding.
## @end itemize
##
## @strong{Example}
## @example
## I = imread("image.png");
## BW = imbinarize(I);
## BW_global = imbinarize(I, "global");  # same as imbinarize(I)
## BW_adaptive = imbinarize(I, "adaptive");
## BW_thresh_08 = imbinarize(I, 0.8);
## @end example
##
## @strong{See Also}
## @seealso{graythresh, adaptthresh, im2bw}
##
## @end deftypefn

function BW = imbinarize (im, varargin)

  if (nargin == 0)
    print_usage ();
  elseif (! isimage(im))
    error ("imbinarize: first argument must be an image")
  endif

# Convert to double only if needed
  if isa (im, "int8")   # imcast does not handle int8, int32 and uint32
    im = (double (im) + 128) / 255;
  elseif isa (im, "int32")
    im = (double (im) + 2 ^ 31) / (2 ^ 32 - 1);
  elseif isa (im, "uint32")
    im = double (im) / (2 ^ 32 - 1);
  elseif (! (isa (im, "double")))
    im = imcast (im, "double");
  endif

  # Parse input arguments
  params = parse_imbinarize_inputs (im, varargin{:});

  if ! strcmp(params.method, "global")
    # Check if the image is a 2D grayscale image
    sz = size (im);
    if ! (numel (im) <= 2 || all (sz(3:end) == 1))
      error("imbinarize currently supports only 2D grayscale image inputs for 'adaptive' threshold")
    endif
  endif


  if isempty(params.threshold)
    # calculating threshold
    switch params.method
      case "global"
         params.threshold = graythresh(im);
      case "adaptive"
         params.threshold = adaptthresh(im, params.Sensitivity,  ...
                "ForegroundPolarity", params.ForegroundPolarity);
    endswitch
  endif

  BW = im > params.threshold;

endfunction

function param_out = parse_imbinarize_inputs(im, varargin)

  # This function handles input parsing and validation for the imbinarize function

  # Default parameters

  param_out = struct(...
    "threshold", [], ...
    "method", "global", ...
    "ForegroundPolarity", "bright", ...
    "Sensitivity", 0.5 ...
    );

  if (isempty(varargin))
    return
  endif

  if (ischar (varargin{1}))
    method = validateMethod(varargin{1});
    if !isempty(method)
      param_out.method = method;
      varargin(1) = [];
    endif
  elseif (isnumeric(varargin{1}))
    if ! isscalar(varargin{1})
      if (! all(size(varargin{1}) == size(im)))
        error("size of image and threshold should be the same")
      endif
    endif
    param_out.threshold = varargin{1};
    varargin(1) = [];
  endif

  if (isempty(varargin))
    return
  endif

  if (strcmp(param_out.method, "adaptive"))
    % Create input parser object
    p = inputParser;
    p.CaseSensitive = false;
    p.FunctionName = "imbinarize";

    # Add optional parameters with validation functions
    addParameter(p, "Sensitivity", 0.5, @validateSensitivity);
    addParameter(p, "ForegroundPolarity", "bright", @validatePolarity);

    # Parse inputs
    parse(p, varargin{:});

    # Return parsed parameters
    param_out.Sensitivity = p.Results.Sensitivity;
    # Allow partial matching
    param_out.ForegroundPolarity = validatestring(p.Results.ForegroundPolarity,...
        {"bright", "dark"}, "imbinarize", "ForegroundPolarity");
  else
    error("imbinarize: method = %s - should be 'global' or 'adaptive'", varargin{1})
  endif

endfunction

% Validation functions
function validateSensitivity(x)
  validateattributes(x, {"numeric"}, ...
    {"scalar", "real", "finite", ">=", 0, "<=", 1}, ...
    "imbinarize", "Sensitivity");
endfunction

function validatePolarity(x)
  validatestring(x, {"bright", "dark"}, "imbinarize", "ForegroundPolarity");
endfunction

function method = validateMethod(x)
  try
    method = validatestring(x, {"global", "adaptive"});
  catch
    method = [];
  end_try_catch
endfunction


%!test
%! assert(imbinarize(1),  logical([1]));
%!test
% Test with a manual threshold
%! img = [0.1, 0.5, 0.7; 0.3, 0.6, 0.9];
%! threshold = 0.5;
%! expected_result = [0, 0, 1; 0, 1, 1];
%! binarized_img = imbinarize(img, threshold);
%! assert(isequal(binarized_img, expected_result));
%!test
% Test with default threshold (Otsu method)
%! img = [0.2, 0.4; 0.6, 0.8];
%! expected_result = [0, 0; 1, 1];
%! binarized_img = imbinarize(img);
%! assert(isequal(binarized_img, expected_result));
%!test
% Test with all elements at threshold
%! img = [0.1, 0.1, 0.1; 0.1, 0.1, 0.1];
%! threshold = 0.1;
%! expected_result = [0, 0, 0; 0, 0, 0];
%! binarized_img = imbinarize(img, threshold);
%! assert(isequal(binarized_img, expected_result));
%!test
% Test with all elements above threshold
%! img = [0.1, 0.1, 0.1; 0.1, 0.1, 0.1];
%! threshold = 0.05;
%! expected_result = [1, 1, 1; 1, 1, 1];
%! binarized_img = imbinarize(img, threshold);
%! assert(isequal(binarized_img, expected_result));
%!test
% Test with a different threshold method (e.g., adaptive threshold)
%! img = [0.1, 0.5, 0.3; 0.4, 0.6, 0.9];
%! method = "adaptive";
%! binarized_img = imbinarize(img, method);
%! expected_result_adaptive = [0, 0, 0; 0, 0, 0];
%! assert(isequal(binarized_img, expected_result_adaptive));
%!test
% Test with a different data type (e.g., integer image)
%! img = uint8([10, 50, 70; 30, 60, 90]);
%! threshold = 0.2;
%! expected_result = [0, 0, 1; 0, 1, 1];
%! binarized_img = imbinarize(img, threshold);
%! assert(isequal(binarized_img, expected_result));
%!test
% Test with a color image, with "global" option
%! img = cat (3, [0.1, 0.5; 0.3, 0.6], [0.2, 0.4; 0.5, 0.7], [0.3, 0.5; 0.6, 0.8]);
%! threshold = 0.4;
%! expected_result = cat(3, [0, 1; 0, 1], [0, 0; 1, 1], [0, 1; 1, 1]);
%! binarized_img = imbinarize(img, threshold);
%! assert(isequal(binarized_img, expected_result));
%!test
%! binarized_img = imbinarize ([0.1, 0.5; 0.3, 0.6], "adaptive", "ForegroundPolarity", "bright");
%! assert(isequal(binarized_img, [0, 0; 0, 0]));
%! binarized_img = imbinarize ([0.1, 0.5; 0.3, 0.6], "adaptive", "ForegroundPolarity", "dark");
%! assert(isequal(binarized_img, [1, 1; 1, 1]));
%! binarized_img = imbinarize ([0.1, 0.5; 0.3, 0.6], "adaptive", "Sensitivity", 0.5);
%! assert(isequal(binarized_img, [0, 0; 0, 0]));
%! binarized_img = imbinarize ([0.1, 0.5; 0.3, 0.6], "adaptive", "Sensitivity", 0.9);
%! assert(isequal(binarized_img, [1, 1; 1, 1]));

%!test
%! # test all image types
%! # int8
%! expected = [ ...
%!  1  1  0  0  1;
%!  1  0  0  1  1;
%!  0  0  1  1  1;
%!  0  0  1  1  0;
%!  0  1  1  0  0];
%! assert(isequal(imbinarize(int8(magic(5))), logical(expected)))
%!
%! # int16
%! assert(isequal(imbinarize(int16(magic(5) * 256)), logical(expected)))
%!
%! # int32
%! assert(isequal(imbinarize(int32(magic(5) * 2 ^ 26)), logical(expected)))
%!
%! # uint8
%! expected = [ ...
%!  1  1  0  0  1;
%!  1  0  0  1  1;
%!  0  0  1  1  1;
%!  0  0  1  1  0;
%!  0  1  1  0  0];
%! assert(isequal(imbinarize(uint8(magic(5))), logical(expected)))
%!
%! # uint16
%! assert(isequal(imbinarize(uint16(magic(5) * 256)), logical(expected)))
%!
%! # uint32
%! assert(isequal(imbinarize(uint32(magic(5) * 2 ^ 26)), logical(expected)))
%!
%! # single
%! expected = [ ...
%!  1  1  0  1  1;
%!  1  1  1  1  1;
%!  1  1  1  1  1;
%!  1  1  1  1  0;
%!  1  1  1  0  1];
%! assert(isequal(imbinarize(single(magic(5) / 5)), logical(expected)))
%!
%! # double
%! assert(isequal(imbinarize(double(magic(5) / 5)), logical(expected)))
%!
%! # tests with "adapt"
%! assert(isequal(sum(sum(imbinarize(int8(magic(20)), "adapt"))), 80))
%! assert(isequal(sum(sum(imbinarize(int16(magic(200)), "adapt"))), 14710))
%! assert(isequal(sum(sum(imbinarize(int32(magic(200) * 2^20), "adapt"))), 1629))
%! assert(isequal(sum(sum(imbinarize(uint8(magic(20)), "adapt"))), 174))
%! assert(isequal(sum(sum(imbinarize(uint16(magic(200)), "adapt"))), 17998))
%! assert(isequal(sum(sum(imbinarize(uint32(magic(200) * 2^20), "adapt"))), 3855))
%! assert(isequal(sum(sum(imbinarize(single(magic(20) / 400), "adapt"))), 174))
%! assert(isequal(sum(sum(imbinarize(double(magic(20) / 400), "adapt"))), 174))

## Test input validation
%!error imbinarize ()
%!error imbinarize ([])
%!error imbinarize(rand(10, 10, 3), "adapt")
%!error imbinarize (1, 2, 3, 4)
%!error imbinarize ({"a", "b"; "c", "d"})
%!error imbinarize ([0.1, 0.5; 0.3, 0.6], "invalid")
%!error imbinarize ([0.1, 0.5; 0.3, 0.6], [0.3, 0.4])
%!error imbinarize ([0.1, 0.5; 0.3, 0.6], "adaptive", "Sensitivity", 1.1)
%!error imbinarize ([0.1, 0.5; 0.3, 0.6], "global", "Sensitivity", 0.9);
