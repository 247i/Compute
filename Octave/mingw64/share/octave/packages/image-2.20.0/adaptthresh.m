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
## @deftypefn {Function File} {@var{T} =} adaptthresh (@var{img})
## @deftypefnx {Function File} {@var{T} =} adaptthresh (@var{img}, @var{sensitivity})
## @deftypefnx {Function File} {@var{T} =} adaptthresh (@dots{}, @var{name}, @var{value}, @dots{})
##
## Compute local threshold value for each pixel
## using local mean intensity in the neighborhood of each pixel.
##
## Parameters:
## @table @samp
## @item @var{img}
## Input image, specified as a 2-D grayscale image.
## Image type can be int8, uint8, int16, uint16, int32, uint32, single or double.
##
## @item @var{sensitivity}
## Sensitivity factor, specified as a scalar in the range [0, 1].
## Higher values make the threshold more sensitive, resulting in more
## foreground pixels. Default value = 0.5
##
## @item @var{name}, @var{value}
## Additional options as name-value pairs:
## @item Statistic
## Method used to compute the threshold. Valid options are:
## @table @samp
## @item "mean"
## Computes the threshold based on the local mean intensity. This method assumes that
## the foreground and background have different mean intensities.
##
## @item "median"
## Computes the threshold using the local median intensity. This method is more robust to
## noise and outliers compared to the mean method.
##
## @item "gaussian"
## Uses a weighted average where weights are determined by a Gaussian window. This method
## smooths the local intensity variations and can be more effective in noisy images.
##
## @end table
##
## @item NeighborhoodSize
## Size of the local neighborhood, specified as a positive scalar or a 2-element vector
## [m n]. m & n should be odd integers.
## By default, the window size is determined based on the size of the input image.
## For an image of size MxN, the default window size is computed as:
##
## @example
## m = 2 * floor (M / 16) + 1
## n = 2 * floor (N / 16) + 1
## @end example
##
## This ensures the window size is odd and appropriately scaled relative to the image dimensions.
##
## @item ForegroundPolarity
## Defines object polarity:
## @itemize
## @item "bright" (default): Assumes bright foreground on dark background
## @item "dark": Assumes dark foreground on bright background
## @end itemize
## @end table
##
## @strong{Outputs}
## @table @var
## @item T
## Thresholds image, where each pixel present the normalized intensity.
## The values of @var{T} are in the range @qcode{[0, 1]}
## @end table
##
## @strong{Example}
## @example
## I = imread ("example.png");
## T = adaptthresh (I, 0.5, "Statistic", "mean", "NeighborhoodSize", [15 15]);
## BW = imbinarize (I, T);
## imshow (BW);
## @end example
##
## @seealso{imbinarize, graythresh, imboxfilt, medfilt2, imgaussfilt}
## @end deftypefn

function T = adaptthresh (img, varargin)

  if (nargin == 0)
    print_usage ();
  elseif (! isimage (img))
    error ("adaptthresh: first argument must be an image")
  endif

  # Check if the image is a 2D grayscale image
  sz = size (img);
  if ! (numel (img) <= 2 || all (sz(3:end) == 1))
    error("adaptthresh currently supports only 2D grayscale image inputs")
  endif
  if (isa (img, "logical"))
    error ("adaptthresh does not support logical type images")
  endif

  # Convert to double only if needed
  if isa (img, "int8")   # imcast does not handle int8, int32 and uint32
    img = (double (img) + 128) / 255;
  elseif isa (img, "int32")
    img = (double (img) + 2 ^ 31) / (2 ^ 32 - 1);
  elseif isa (img, "uint32")
    img = double (img) / (2 ^ 32 - 1);
  elseif (! (isa (img, "double")))
    img = imcast (img, "double");
  endif

  # Parse inputs
  params = parse_adapt_thresh_inputs (img, varargin{:});

  switch (lower (params.Statistic))
    case "mean"
      T = imboxfilt (img, params.NeighborhoodSize);
    case "median"
      params.NeighborhoodSize(1) = min (params.NeighborhoodSize(1), size (img, 1));
      params.NeighborhoodSize(2) = min (params.NeighborhoodSize(2), size (img, 2));
      T = medfilt2 (img, params.NeighborhoodSize, "symmetric");
    case "gaussian"
      T = imgaussfilt (img,  params.NeighborhoodSize);
    otherwise
      error ("adaptthresh: unsupported smoothing type '%s'", params.Statistic);
  endswitch

  if (strcmpi (params.ForegroundPolarity, "bright"))
    T = T * (1.6 - params.Sensitivity);
  else
    T = T * (0.4 + params.Sensitivity);
  endif

  T = min (max (T, 0), 1);

endfunction

function param_out = parse_adapt_thresh_inputs (img, varargin)

  # This function handles input parsing and validation for the adaptthresh function

  # Default parameters
  neighborhood_size = 2 * floor (size (img) / 16) + 1;
  sensitivity = 0.5;

  param_out = struct(...
  "NeighborhoodSize", neighborhood_size, ...
  "ForegroundPolarity", "bright", ...
  "Sensitivity", sensitivity, ...
  "Statistic", "mean" ...
  );

  if (isempty (varargin))
    return
  endif

  if (! ischar (varargin{1}))
    sensitivity = varargin{1};
    validateSensitivity (sensitivity)
    if (sensitivity < 0 || sensitivity > 1)
      error ("adaptthresh: sensitivity should be in the range [0,1]");
    endif
    varargin(1) = [];
  endif

  if (length (varargin) == 0)
    param_out.Sensitivity = sensitivity;
    return
  endif

  # Create input parser object
  p = inputParser;
  p.CaseSensitive = false;
  p.FunctionName = "adaptthresh";

  # Add optional parameters with validation functions
  addParameter (p, "NeighborhoodSize", neighborhood_size, @validateNeighborhoodSize);
  addParameter (p, "ForegroundPolarity", "bright", @validatePolarity);
  addParameter (p, "Statistic", "mean", @validateStatistic);

  # Parse inputs
  parse (p, varargin{:});

  # Return parsed parameters
  param_out = p.Results;
  param_out.Sensitivity = sensitivity;
  # Allow partial matching
  param_out.ForegroundPolarity = validatestring (param_out.ForegroundPolarity,...
  {"bright", "dark"}, "adaptthresh", "ForegroundPolarity");
  param_out.Statistic = validatestring (param_out.Statistic, ...
  {"mean", "median", "gaussian"}, "adaptthresh", "Statistic");

endfunction

# Validation functions
function validateSensitivity (x)
  validateattributes(x, {"numeric"}, ...
  {"scalar", "real", "finite", ">=", 0, "<=", 1}, ...
  "adaptthresh", "Sensitivity");
endfunction

function validateNeighborhoodSize (x)
  validateattributes(x, {"numeric"}, ...
  {"vector", "positive", "integer", "numel", 2}, ...
  "adaptthresh", "NeighborhoodSize");
  if any (mod (x, 2) == 0)
    error("NeighborhoodSize values must be odd numbers");
  end
endfunction

function validatePolarity (x)
  validatestring (x, {"bright", "dark"}, "adaptthresh", "ForegroundPolarity");
endfunction

function validateStatistic (x)
  validatestring (x, {"mean", "median", "gaussian"}, "adaptthresh", "Statistic");
endfunction

%!test
%! % Test with a simple binary image
%! I = [0 0 0 0 0; 0 1 1 1 0; 0 1 1 1 0; 0 1 1 1 0; 0 0 0 0 0];
%! T = adaptthresh(I);
%! assert(T, [0 0 0 0 0; 0 1 1 1 0; 0 1 1 1 0; 0 1 1 1 0; 0 0 0 0 0]);

%!test
%! % Test with a sensitivity factor
%! I =  [25 50 26 51 26; 51 230 204 230 51; 26 204 230 204 26; 51 230 204 230 51; 26 51 26 51 26];
%! I = uint8(I);
%! T = adaptthresh(I, 0.5);
%! assert(T, [0.10784 0.21569 0.11216 0.22000 0.11216
%!            0.22000 0.99216 0.88000 0.99216 0.22000
%!            0.11216 0.88000 0.99216 0.88000 0.11216
%!            0.22000 0.99216 0.88000 0.99216 0.22000
%!            0.11216 0.22000 0.11216 0.22000 0.11216], 1e-5);

%!test
%! % Test with a sensitivity factor
%! I = [0.1 0.2 0.1 0.2 0.1; 0.2 0.9 0.8 0.9 0.2; 0.1 0.8 0.9 0.8 0.1; 0.2 0.9 0.8 0.9 0.2; 0.1 0.2 0.1 0.2 0.1];
%! T = adaptthresh(I, 0.5);
%! assert(T, [0.11 0.22 0.11 0.22 0.11
%!            0.22 0.99 0.88 0.99 0.22
%!            0.11 0.88 0.99 0.88 0.11
%!            0.22 0.99 0.88 0.99 0.22
%!            0.11 0.22 0.11 0.22 0.11], eps);
%! T = adaptthresh(I, 0.5, "Statistic", "Gaussian");
%! assert(T, [0.2233   0.3283   0.3711   0.3283   0.2233
%!            0.3283   0.5483   0.6481   0.5483   0.3283
%!            0.3711   0.6481   0.7771   0.6481   0.3711
%!            0.3283   0.5483   0.6481   0.5483   0.3283
%!            0.2233   0.3283   0.3711   0.3283   0.2233], 5e-5);
%! T = adaptthresh(I, 0.5, "Statistic", "median" ,"NeighborhoodSize", [3, 3]);
%! assert(T, [0.2200   0.2200   0.2200   0.2200   0.2200
%!            0.2200   0.2200   0.8800   0.2200   0.2200
%!            0.2200   0.8800   0.9900   0.8800   0.2200
%!            0.2200   0.2200   0.8800   0.2200   0.2200
%!            0.2200   0.2200   0.2200   0.2200   0.2200], eps);
%! T = adaptthresh(I, 0.5, "Statistic", "mean" ,"NeighborhoodSize", [3, 3]);
%! assert(T, [0.2567   0.3300   0.4400   0.3300   0.2567
%!            0.3300   0.5011   0.6844   0.5011   0.3300
%!            0.4400   0.6844   0.9411   0.6844   0.4400
%!            0.3300   0.5011   0.6844   0.5011   0.3300
%!            0.2567   0.3300   0.4400   0.3300   0.2567], 5e-5);
%! T = adaptthresh(I, 0.5, "Statistic", "median" ,"NeighborhoodSize", [3, 3], "ForegroundPolarity", "bright");
%! assert(T, [0.2200   0.2200   0.2200   0.2200   0.2200
%!            0.2200   0.2200   0.8800   0.2200   0.2200
%!            0.2200   0.8800   0.9900   0.8800   0.2200
%!            0.2200   0.2200   0.8800   0.2200   0.2200
%!            0.2200   0.2200   0.2200   0.2200   0.2200], eps);
%! T = adaptthresh(I, 0.5, "Statistic", "mean" ,"NeighborhoodSize", [3, 3], "ForegroundPolarity", "dark");
%! assert(T, [0.2100   0.2700   0.3600   0.2700   0.2100
%!            0.2700   0.4100   0.5600   0.4100   0.2700
%!            0.3600   0.5600   0.7700   0.5600   0.3600
%!            0.2700   0.4100   0.5600   0.4100   0.2700
%!            0.2100   0.2700   0.3600   0.2700   0.2100], eps);
%! T = adaptthresh(I, 0.5, "Statistic", "gaussian" ,"NeighborhoodSize", [13, 13], "ForegroundPolarity", "dark");
%! assert(T, [0.1064   0.1065   0.1065   0.1065   0.1064
%!            0.1065   0.1066   0.1066   0.1066   0.1065
%!            0.1065   0.1066   0.1066   0.1066   0.1065
%!            0.1065   0.1066   0.1066   0.1066   0.1065
%!            0.1064   0.1065   0.1065   0.1065   0.1064], 5e-5)
%! T = adaptthresh(I, 0.7, "Statistic", "mean" ,"NeighborhoodSize", [13, 13], "ForegroundPolarity", "dark");
%! assert(T, 0.180295857988166 * ones(5,5), 2*eps);
%! T = adaptthresh(I, 0.7, "Statistic", "median" ,"NeighborhoodSize", [13, 13], "ForegroundPolarity", "dark");
%! assert(T, 0.22 * ones(5,5), eps)
%!test
%! % Test with a different method
%! I = rand(10, 10);
%! T_mean = adaptthresh(I, 0.5, "Statistic", "mean");
%! T_median = adaptthresh(I, 0.5, "Statistic", "median");
%! assert(size(T_mean), size(I));
%! assert(size(T_median), size(I))

%!test
%! % Test with specified window size
%! I = rand(20, 20);
%! T = adaptthresh(I, 0.5, "Statistic", "mean", "NeighborhoodSize", [5 5]);
%! assert(size(T), size(I))

%!test
%! # testing all data types
%! # int8
%! expected =  [0.6255   0.6557   0.5565   0.5867   0.6169;
%!              0.6514   0.5737   0.5824   0.6125   0.6212;
%!              0.5694   0.5780   0.6082   0.6384   0.6471;
%!              0.5953   0.6039   0.6341   0.6427   0.5651;
%!              0.5996   0.6298   0.6600   0.5608   0.5910];
%! assert(adaptthresh(int8(magic(5))), expected, 5e-5)
%!
%! # uint8
%! expected = [7.3333e-02   1.0353e-01   4.3137e-03   3.4510e-02   6.4706e-02;
%!             9.9216e-02   2.1569e-02   3.0196e-02   6.0392e-02   6.9020e-02;
%!             1.7255e-02   2.5882e-02   5.6078e-02   8.6275e-02   9.4902e-02;
%!             4.3137e-02   5.1765e-02   8.1961e-02   9.0588e-02   1.2941e-02;
%!             4.7451e-02   7.7647e-02   1.0784e-01   8.6275e-03   3.8824e-02];
%! assert(adaptthresh(uint8(magic(5))), expected, 5e-6)
%!
%! # int16
%! expected = [ ...
%!   0.550293736171511   0.550411230640116   0.550025177386130   0.550142671854734   0.550260166323339;
%!   0.550394445716030   0.550092317082475   0.550125886930648   0.550243381399252   0.550276951247425;
%!   0.550075532158389   0.550109102006561   0.550226596475166   0.550344090943771   0.550377660791943;
%!   0.550176241702907   0.550209811551080   0.550327306019684   0.550360875867857   0.550058747234302;
%!   0.550193026626993   0.550310521095598   0.550428015564202   0.550041962310216   0.550159456778820];
%! assert(adaptthresh(int16(magic(5))), expected, 5e-16)
%!
%! # uint16
%! expected = [ ...
%!   2.8534e-04   4.0284e-04   1.6785e-05   1.3428e-04   2.5177e-04;
%!   3.8605e-04   8.3925e-05   1.1749e-04   2.3499e-04   2.6856e-04;
%!   6.7140e-05   1.0071e-04   2.1820e-04   3.3570e-04   3.6927e-04;
%!   1.6785e-04   2.0142e-04   3.1891e-04   3.5248e-04   5.0355e-05;
%!   1.8463e-04   3.0213e-04   4.1962e-04   3.3570e-05   1.5106e-04];
%! assert(adaptthresh(uint16(magic(5))), expected, 5e-6)
%!
%! # int32
%!
%! expected = [ ...
%!   0.8422   0.9625   0.5672   0.6875   0.8078;
%!   0.9453   0.6359   0.6703   0.7906   0.8250;
%!   0.6188   0.6531   0.7734   0.8938   0.9281;
%!   0.7219   0.7563   0.8766   0.9109   0.6016;
%!   0.7391   0.8594   0.9797   0.5844   0.7047];
%! assert(adaptthresh(int32(magic(5) * 2^26)), expected, 5e-5)
%!
%! # uint32
%! expected = [ ...
%!   1.000000   1.000000   0.068750   0.550000   1.000000;
%!   1.000000   0.343750   0.481250   0.962500   1.000000;
%!   0.275000   0.412500   0.893750   1.000000   1.000000;
%!   0.687500   0.825000   1.000000   1.000000   0.206250;
%!   0.756250   1.000000   1.000000   0.137500   0.618750];
%! assert(adaptthresh(uint32(magic(5) * 2^28)), expected, 5e-10)
%!
%! # single
%! expected = [ ...
%!   1.2331e-44   1.8497e-44            0   6.1657e-45   1.2331e-44;
%!   1.8497e-44   3.0829e-45   6.1657e-45   1.0790e-44   1.2331e-44;
%!   3.0829e-45   4.6243e-45   9.2486e-45   1.5414e-44   1.6956e-44;
%!   7.7071e-45   9.2486e-45   1.5414e-44   1.5414e-44   3.0829e-45;
%!   9.2486e-45   1.3873e-44   1.8497e-44   1.5414e-45   6.1657e-45];
%! assert(adaptthresh(single(magic(5)/2^150)), expected, 5e-49)
%!
%! # double
%! expected = [ ...
%!   1.3102e-44   1.8497e-44   7.7071e-46   6.1657e-45   1.1561e-44;
%!   1.7726e-44   3.8536e-45   5.3950e-45   1.0790e-44   1.2331e-44;
%!   3.0829e-45   4.6243e-45   1.0019e-44   1.5414e-44   1.6956e-44;
%!   7.7071e-45   9.2486e-45   1.4644e-44   1.6185e-44   2.3121e-45;
%!   8.4779e-45   1.3873e-44   1.9268e-44   1.5414e-45   6.9364e-45];
%! assert(adaptthresh(double(magic(5)/2^150)), expected, 5e-49)

%!error
%! % Test with non-grayscale image (3D array)
%! I = rand(10, 10, 3);
%! adaptthresh(I);

% Test with non-numeric input
%! error(adaptthresh("invalid_input"))
% Test with logical input
%! error(adaptthresh(magic(5) > 2))
% Test with invalid sensitivity factor (out of range)
%!error (adaptthresh(rand(10, 10), 1.5))
%! #  Test with invalid sensitivity factor (out of range)
%!error (adaptthresh(rand(10, 10), -1.5))
%! #  Test with non-scalar sensitivity factor
%!error (adaptthresh(rand(10, 10), [0.5, 0.5]))
%! #  Test with invalid method name
%!error (adaptthresh(rand(10, 10), "unknown_method"))
%! #  Test with negative window size
%! error (adaptthresh(rand(10, 10), "NeighborhoodSize", [-5 -5]))
%! #  Test with even window size
%!error (adaptthresh(rand(10, 10), "NeighborhoodSize", [5 4]))
%! # Test with RGB image
%!error (adaptthresh(rand(10, 10, 3)))
