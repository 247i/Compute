## Copyright (C) 2023
## Johannes Wirbser <wirbserj@freenet.de> and
## Sarah Tiefert <st_swdeveloper@freenet.de>
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
## @deftypefn  {Function File} @var{J} = imboxfilt(@var{img})
## @deftypefnx {Function File} @var{J} = imboxfilt(@dots{_}, @var{fs})
## @deftypefnx {Function File} @var{J} = imboxfilt(@dots{}, @var{name}, @var{value}, @dots{} )
## Produces box filtering of an image, quicker than imfilter.
##
## Parameters:
## @table @samp
## @item @var{img}
## The image to be filtered. Must be a matrix of numeric values.
## @item @var{fs}
## Size for the filter matrix.
## Must be a positive, odd integer or 2-element vector of positive odd
## integers. If @var{fs} is scalar, a squared box filter is used.
## Default is 3x3.
## @item @var{name}, @var{value}
## Additional options, given as name-value pairs:
## @table @samp
## @item padding
## Determines how the image is padded. Value can be one of the following:
## @table @samp
## @item S
## Pads the image with the scalar value S.
## @item "replicate" (default)
## Pads the image with the border pixel value.
## @item "symmetric"
## Pads the image by mirroring it at the image border.
## @item "circular"
## Pads the image with pixel values from the opposite image border,
## essentially treating the image as periodic.
## @end table
## @item NormalizationFactor
## Normalization factor used, has to be a numeric scalar.
## Default is 1/(l*w), where l is the length and
## w is the width of the filter matrix.
## @end table
## @end table
## The computation is performed using double precision floating point number,
## but the class of the input image is preserved.
## The function uses convolution based filtering or filtering with the integral
## image, depending on an internal heuristic.
##
## @seealso{imfilter, imgaussfilt}
## @end deftypefn

function filtered_img = imboxfilt (img, varargin)
  if (nargin < 1)
    print_usage ();
  endif
  if (islogical (img) || ! isimage (img) )  # test if img is a proper image
    error ("imboxfilt: img needs to be an image");
  endif
  ## convert img into double and remember original type
  img_class = class (img);
  img = double (img);
  ## get optional inputs from varargin, or retun default values
  opt_arg = varargin;
  [filter_size, padding, normalization] = handle_optional_input (opt_arg);

  ## do the filtering
  ## determine which filtering method should be used.
  ## this is based on our internal testing of the algorithms
  if ((filter_size(1) + filter_size(2)) > 200)
    filtered_img = integral_image_filtering (img, filter_size, ...
                                               padding, normalization);
  else
    filtered_img = convolution_based_filtering (img, filter_size, ...
                                                  padding, normalization);
  endif
  ## turn result back to original datatype
  filtered_img = cast (filtered_img, img_class);
endfunction

## helper functions:
function res = isodd (value)
  res = all ((mod (value, 2) == 1));
endfunction

function [filter_size, padding, normalization] = handle_optional_input (opt_arg)

  num_opt_arg = length (opt_arg);      # how many optional arguments?
  size_isgiven = isodd (num_opt_arg);  # did the user input a size?
  nv_pair_isgiven = num_opt_arg > 1;   # did the user input a name value pair?
  filter_size = get_filter_size (size_isgiven, opt_arg);
  [padding, normalization] = get_name_value_pairs (size_isgiven, ...
                                                   nv_pair_isgiven, ...
                                                   opt_arg, ...
                                                   filter_size);
endfunction

function filter_size = get_filter_size (size_isgiven, opt_arg)
  filter_size = [3, 3];
  if (size_isgiven)
    filter_size = opt_arg{1};
    ## check for corectness of filter_size
    if (! isodd (filter_size) || ...  # only allow odd numbers
         any (filter_size < 0) || ...  # only allow positive numbers
         any (filter_size != round (filter_size)))  # only allow integers
        error ("imboxfilt: fs has to be an odd, positive integer");
    endif
    if (! isscalar (filter_size))
      dim = size (filter_size);
      if ((dim(1) + dim(2)) > 3) # does the given vector have the right format?
        error (["imboxfilt: fs must be scalar or vector " ...
                "with two values"]);
      endif
    endif
  endif
  if (isscalar (filter_size))
    filter_size = [filter_size, filter_size];
  endif
endfunction

function [padding, normalization] = get_name_value_pairs (size_isgiven, ...
                            nv_pair_isgiven, opt_arg, filter_size)
  padding_options = {"replicate", "circular", "symmetric"};
  padding = "replicate";
  normalization = 1/9;
  if (isscalar (filter_size))
    normalization = 1 / (filter_size * filter_size);
  else
    normalization = 1 / (filter_size(1) * filter_size(2));
  endif
  indexFirstName = 1 + double (size_isgiven);
  if (nv_pair_isgiven)
  ## check what kind of name value pairs are given and test input
    for idx = (indexFirstName:2:length (opt_arg))
      name = opt_arg{idx};
      value = opt_arg{idx+1};
      if ! ischar (name)
        error ("imboxfilt: name must be string")
      endif
      if (strcmpi (name, "padding"))
        if ((! isnumeric(value) || ! isscalar(value)) ...
            && ! any (strcmpi (padding_options, value)))
          error (["imboxfilt: padding option must be a numeric scalar, ", ...
                  "'replicate', 'circular' or 'symmetric'"])
        endif
        padding = value;
      elseif(strcmpi (name, "normalizationFactor"))
        if (! isnumeric (value) || ! isscalar (value))
          error ("imboxfilt: NormalizationFactor must be a numeric scalar")
        endif
          normalization = value;
      else
        error (["imboxfilt: cannot handle option '", name, "'"]);
      endif
    endfor
  endif
endfunction

function [filtered_img] = convolution_based_filtering (img, filter_size, ...
                                                       padding, normalization)
  ## remember original image shape:
  img_shape = size (img);
  ## pad image
  padded_image = pad_image (img, filter_size, padding);
  ## create boxfilter
  filter1 = ones (filter_size(1), 1);
  filter2 = ones (1, filter_size(2)) * normalization;
  ## filter Image
  [image_rows, image_columns, image_channels, extra_dimensions] = size (img);
  ## change shape to 3 dim matrix
  for channels = (image_channels*extra_dimensions):-1:1
    ## filter the Image with filter1
    im1(:,:,channels) = conv2 (padded_image(:,:,channels), filter1, "valid");
    ## filter the Image with filter2
    filtered_img(:,:,channels) = conv2 (im1(:,:,channels), filter2, "valid");
  endfor
  ## turn result back to original shape
  filtered_img = reshape (filtered_img, img_shape);
endfunction

function [filtered_img] = integral_image_filtering (img, filter_size, ...
                                                    padding, normalization)
  ## filter the image by using the integral image method.
  ## the integral image is used to more easily calculate the mean of the image.
  ## to do so, we get subimages A, B, C and D from the integral image.
  ## mean of the image = (D + A - B - C) * normalization

  ## remember original image shape:
  img_shape = size(img);
  ## pad image
  padded_image = pad_image(img, filter_size, padding);
  ## determinen start position of Image D
  imgD_start_xaxis = (1+filter_size(1));
  imgD_start_yaxis = (1+filter_size(2));
  ## get size values to conserve original shape:
  [image_rows, image_columns, image_channels, extra_dimensions] = size (img);
  ## change shape to 3 dim matrix
  for channel = (image_channels*extra_dimensions):-1:1
    int_img = integralImage (padded_image (:,:, channel));
    [intimgRows, intimgColums] = size (int_img);
    ## get images A, B, C, and D
    imgD = int_img(imgD_start_xaxis:intimgRows, imgD_start_yaxis:intimgColums);
    imgA = int_img(1:size (img)(1), 1:size (img)(2));
    imgB = int_img(1:size (img)(1), imgD_start_yaxis:intimgColums);
    imgC = int_img(imgD_start_xaxis:intimgRows, 1:size(img)(2));
    ## calculate and normalize image
    filtered_img(:, :, channel) = (imgD + imgA - imgB - imgC) * normalization;
  endfor
  ## turn result back to original shape
  filtered_img = reshape (filtered_img, img_shape);
endfunction

function padded_image = pad_image(img, filter_size, padding)
  ## create padding
  if (isscalar(filter_size))
    [padding_width, padding_hight] = deal (floor(filter_size/2));
    filter_size = [filter_size, filter_size];
  else
    padding_width = floor (filter_size(1)/2);
    padding_hight = floor (filter_size(2)/2);
  endif
  padded_image = padarray(img, [padding_width, padding_hight], padding);
endfunction

## just img test, correct syntax
%!assert (imboxfilt(ones (5) * 9));
%!assert (isa (imboxfilt (uint8  (ones (5))), "uint8"));
%!assert (isa (imboxfilt (uint16 (ones (5))), "uint16"));
%!assert (isa (imboxfilt (uint32 (ones (5))), "uint32"));
%!assert (isa (imboxfilt (uint64 (ones (5))), "uint64"));
%!assert (isa (imboxfilt (int8   (ones (5))), "int8"));
%!assert (isa (imboxfilt (int16  (ones (5))), "int16"));
%!assert (isa (imboxfilt (int32  (ones (5))), "int32"));
%!assert (isa (imboxfilt (single (ones (5))), "single"));
%!assert (isa (imboxfilt (double (ones (5))), "double"));

## illegal datatypes for img
%!error (imboxfilt (true (5)));
%!error (imboxfilt (5i+9));
%!error (imboxfilt ({"sdg","sdgsd"}));
%!error (imboxfilt ("sdjgkhsdkl"));
%!error (imboxfilt (struct("imgD_start_xaxis", "34", "imgD_start_yaxis", "67")))

## just img test, illegal syntax
%!error (imboxfilt ());
%!error (imboxfilt ("asdf"));

## tests for filter_size
## does the correct syntax work?
%!test
%! padded_img = ones (3);
%! assert (imboxfilt (padded_img, 9));
%!test
%! padded_img = ones (3);
%! assert (imboxfilt (padded_img, [3, 7]));

## throw error if filter_size isn't an odd integer
%!error (imboxfilt (ones (3), 2));
%!error (imboxfilt (ones (3), "asdf"));
%!error (imboxfilt (ones (3), 2.4));
%!error (imboxfilt (ones (3), 3.5));
%!error (imboxfilt (ones (3), -3));
%!error (imboxfilt (ones (3), [3,-5]));
%!error (imboxfilt (ones (3), [3.5, 3]));
%!error (imboxfilt (ones (3), [3, 4]));
%!error (imboxfilt (ones (3), [6, 11]));

## throw error if filter_size vector is too long:
%!error (imboxfilt(ones (3), [3, 5, 7]));

## tests for padding, valid input
%!assert (imboxfilt (ones (5), "padding", "circular"));
%!assert (imboxfilt (ones (5), "padding", "symmetric"));
%!assert (imboxfilt (ones (3), "padding", "replicate"));
%!assert (imboxfilt (ones (3), "Padding", "Replicate"));
%!assert (imboxfilt (ones (3), "Padding", 5));

## tests for padding, invalid input
%!error (imboxfilt (ones (3),  "circular"));
%!error (imboxfilt (ones (3),  "symmetric", "padding"));
%!error (imboxfilt (ones (3),  "padding"));
%!error (imboxfilt (ones (3),  "padding", "ciircular"));
%!error (imboxfilt (ones (3),  "padding", [2, 3]));

## test for normalization, valid input
## simple input
%!assert (imboxfilt (ones (5), "NormalizationFactor", 2));
%!assert (imboxfilt (ones (5), "normalizationfactor", 2.2));
%!assert (imboxfilt (ones (5), "Normalizationfactor", -1));
%!assert (imboxfilt (ones (5), "normalizationFactor", -1.5));
# input with filter_size:
%!assert (imboxfilt (ones (5), 7, "NormalizationFactor", 3/9));
## input with padding
%!assert (imboxfilt (ones (5), "NormalizationFactor", 1 , "padding", "circular"));
%!assert (imboxfilt (ones (5), "padding", "circular", "NormalizationFactor", 1));
## input with everything
%!assert (imboxfilt (ones (5), [5, 7], "NormalizationFactor", 1, "padding", "circular"));
%!assert (imboxfilt (ones (5), [5, 7], "padding", "circular", "NormalizationFactor", 1));

## normalization, invalid input options
%!error (imboxfilt (ones (5), "n", 1));
%!error (imboxfilt (ones (5), "NormalizationFactor"));
%!error (imboxfilt (ones (5), "Normalizastionfactor", 3));
%!error (imboxfilt (ones (5), "NormalizationFactor", [2, 4]));
%!error (imboxfilt (ones (5), "Normalizationfactor", "asdf"));
%!error (imboxfilt (ones (5), "normalizationFactor", "2"));
%!error (imboxfilt (ones (5), "NormalizationFactor", 1 , "padding", "circular", "NormalizastionFactor", [2, 1]));
%!error (imboxfilt (ones (5), "padding", "NormalizationFactor", 2, "circular", "NormalizastionFactor", 1));
%!error (imboxfilt (ones (5), "NormalizationFactor", [1, 4], "padding", "circular", "NormalizastionFactor", 2));

## normalization, simple functionality:
%!assert (imboxfilt (ones (5), "normalizationfactor", 1), ones (5) * 9);
%!assert (imboxfilt (ones (5), "normalizationfactor", 2), ones (5) * 18);
%!assert (imboxfilt (ones (5), "normalizationfactor", 100), ones (5) * 900);
%!assert (imboxfilt (ones (5), "normalizationfactor", 0.1), ones (5) * 0.9, eps);
%!assert (imboxfilt (ones (5), "normalizationfactor", 0), zeros (5));

## tests for combinations of parameters
%!assert (imboxfilt (ones (8)));
%!assert (imboxfilt (ones (8), 3));
%!assert (imboxfilt (ones (8), "padding", "circular"));
%!assert (imboxfilt (ones (8), 3, "padding", "circular"));
%!assert (imboxfilt (ones (8), "NormalizationFactor", 5));
%!assert (imboxfilt (ones (8), 3, "NormalizationFactor", 5));
%!assert (imboxfilt (ones (8), "padding", "circular", "NormalizationFactor", 5));
%!assert (imboxfilt (ones (8), 3, "padding", "circular", "NormalizationFactor", 5));
%!error  (imboxfilt (ones (8), 3, 3));
%!error  (imboxfilt (ones (8), 3, 3, "padding", "circular"));

## functional tests:
# does integral img filtering work?
%!assert (imboxfilt(ones (200), [89, 121]), ones (200))
%!assert (imboxfilt(ones (200), 199), ones (200))

% does imboxfilt filter correctly?
%!test
%! input = ones (3) * 3;
%! expected = input;
%! output = imboxfilt (input);
%! assert (output, expected);

%!test
%! input = [1, 1, 1; 10, 10, 10; 100, 100, 100];
%! expected= [37, 37, 37; 37, 37, 37; 37, 37, 37];
%! output = imboxfilt (input, 3, "padding", "circular");
%! assert (output, expected, eps);

%!test
%! input = [1, 1, 1; 10, 10, 10; 100, 100, 100];
%! expected = [4, 4, 4; 37, 37, 37; 70, 70, 70];
%! output = imboxfilt (input, 3, "padding", "replicate");
%! assert (output, expected, eps);

%!test
%! input = [1 1 1 1 1 1
%!          1 2 2 2 2 1;
%!          1 2 2 2 2 1;
%!          1 2 2 2 2 1;
%!          1 2 2 2 2 1;
%!          1 1 1 1 1 1];
%! expected = [1.16, 1.24, 1.32, 1.32, 1.24, 1.16;
%!             1.24, 1.36, 1.48, 1.48, 1.36, 1.24;
%!             1.32, 1.48, 1.64, 1.64, 1.48, 1.32;
%!             1.32, 1.48, 1.64, 1.64, 1.48, 1.32;
%!             1.24, 1.36, 1.48, 1.48, 1.36, 1.24;
%!             1.16, 1.24, 1.32, 1.32, 1.24, 1.16];
%! output = imboxfilt (input, 5, "padding", "replicate");
%! assert (output, expected, eps);

%!test
%! input = [1 1 1 1 1 1
%!          1 2 2 2 2 1;
%!          1 2 2 2 2 1;
%!          1 2 2 2 2 1;
%!          1 2 2 2 2 1;
%!          1 1 1 1 1 1];
%! expected = [1.36    1.36    1.48    1.48    1.36    1.36
%!             1.36    1.36    1.48    1.48    1.36    1.36
%!             1.48    1.48    1.64    1.64    1.48    1.48
%!             1.48    1.48    1.64    1.64    1.48    1.48
%!             1.36    1.36    1.48    1.48    1.36    1.36
%!             1.36    1.36    1.48    1.48    1.36    1.36];
%! output = imboxfilt (input, 5, "padding", "symmetric");
%! assert (output, expected, eps);

## correctly calculating the average?
%!test
%! input = [5 6 5 6 ;
%!          6 5 6 5 ;
%!          5 6 5 6 ;
%!          6 5 6 5];
%! expected = [49/9, 49/9, 50/9, 50/9;
%!             49/9, 49/9, 50/9, 50/9;
%!             50/9, 50/9, 49/9, 49/9;
%!             50/9, 50/9, 49/9, 49/9];
%! output = imboxfilt (input, 3);
%! assert (imboxfilt (input, 3), expected, 0.0001); # sadly the test only works with this kind of tolerance

## test 3D-matrix as image
%!test
%! m2d = ones (8, 8);
%! padded_img = cat (3,m2d * 5, m2d * 17, m2d * 29);
%! expected = padded_img;
%! output = imboxfilt (padded_img);
%! assert (output, expected, eps);

## test for 4 dim image:
%!test
%! input = zeros (3, 3, 3, 3);
%! input (2,2,:,:) = 9;
%! expected = ones (3, 3, 3, 3);
%! output = imboxfilt (input);
%! assert (output, expected, eps);

## test for 4 dim image, channels are independent
%!test
%! a1 = ones (5);
%! a2 = ones (5) * 2;
%! a3 = ones (5) * 3;
%! a4 = ones (5) * 4;
%! padded_img = cat (4, a1, a2, a3, a4);
%! expected = padded_img;
%! output = imboxfilt (padded_img);
%! assert (output, expected, eps);

## test asymmetrical filter
%!test
%! im = zeros (11);
%! im(6, 6) = 1;
%! out = imboxfilt(im, [3, 7]);
%! assert (sum (out(6,:)), 1/3, eps);
%! assert (sum (out(:,6)), 1/7, eps);

