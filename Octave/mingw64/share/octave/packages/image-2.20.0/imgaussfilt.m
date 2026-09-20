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
## @deftypefn  {Function File} @var{J} = imgaussfilt(@var{img})
## @deftypefnx {Function File} @var{J} = imgaussfilt(@dots{_}, @var{sigma})
## @deftypefnx {Function File} @var{J} = imgaussfilt(@dots{}, @var{name}, @var{value}, @dots{})
##
## Filters an image with a 2D gaussian kernel and returns a smoothed image.
##
## Parameters:
## @table @samp
## @item @var{img}
## The image to be filtered. Must be an image type, cannot be logical or non-numeric.
## @item @var{sigma}
## The standard deviation of the gausian filter. Can be a scalar or a two element vector
## If @var{sigma} is a vector, the function will use a square gaussian kernel.
## By default @var{sigma} is 0.5.
## @item @var{name}, @var{value}
## Additional options as name-value pairs:
## @item padding
## Determines how the image is padded. Value can be one of the following:
## @table @samp
## @item S
## Pads the image with the scalar S.
## @item "replicate" (default)
## Pads the image with the border pixel value.
## @item "symmetric"
## Pads the image by mirroring it at the image border.
## @item "circular"
## Pads the image with pixel values from the opposite image border,
## essentially treating the image as periodic.
## @end table
## @item Filter Domain
## Determines the domain in which to perform the filtering.
## Values can be one of the following:
## @table @samp
## @item "auto"
## The function determines the filter domain based on internal heuristics.
## @item "frequency"
## Perform convolution in the frequency domain.
## @item "spatial"
## Perform convolution in the spatial domain.
## @end table
## @end table
## @seealso{imfilter, imboxfilt}
## @end deftypefn

function filtered_image = imgaussfilt (img, varargin)

  type_of_img = "";
  optional_arguments = [];
  if (nargin < 1)
    print_usage ();
  endif
  if (islogical (img) || ! isimage (img) )  # test if img is a proper image
    error ("imgaussfilt: img needs to be an image");
  endif
  ## convert img into double and remember original type
  img_class = class (img);
  img = double (img);
  ## check if we have optional input arguments
  optional_arguments = varargin;
  ## get inputs, the function returns the default value for any input not given.
  [sigma, padding, filter_size, filter_domain] = handle_optional_input (
                                                 optional_arguments);
  ## create filtermatrix (depending on filter_size and normalization_factor)
  [fil1, fil2] = create_gaussfilter (filter_size, sigma);
  ## create padding
  filter_rows = max (size (fil2));
  filter_cols = max (size (fil1));
  pad_rows = filter_rows / 2;
  pad_cols = filter_cols / 2;
  im = padarray (img, floor ([pad_rows, pad_cols]), padding);

  if (! isodd (filter_rows))
    im = im(2:end,:,:);
  endif
  if (! isodd (filter_cols))
    im = im(:,2:end,:);
  endif


  ## Filter Image
  ## two step filtering is used to increase filtering speed
  ## get size values to conserve original shape:
  [imrows, imcols, imchannels, tmp] = size (img);
  img_shape = size (img);


  if(strcmpi (filter_domain, "auto"))
    if(filter_size(1) + filter_size(2) > 600)
      filter_domain = "frequency";
    else
      filter_domain = "spatial";
    endif
  endif

  ## Change shape to 3 dim matrix
  img = reshape (img, imrows, imcols, (imchannels * tmp));
  im_size = size (im);
  for channels = (imchannels*tmp):-1:1
    if(strcmpi (filter_domain, "frequency"))
      im1 = filter_with_fft (im(:,:,channels), sigma);
      filtered_image(:,:,channels) = im1(
                                  ceil(pad_rows) : im_size(1)-floor(pad_rows),
                                  ceil(pad_cols) : im_size(2)-floor(pad_cols));
    else
      ## Filter the image with fil1
      im1(:,:,channels) = conv2 (im(:,:,channels), fil1, "valid");
      ## Filter the image with fil2
      filtered_image(:,:,channels) = conv2 (im1(:,:,channels), fil2, "valid");
    endif
  endfor
  filtered_image = reshape (filtered_image, img_shape); # turn result back to original shape
  filtered_image = cast (filtered_image, img_class); # turn result back to original datatype
endfunction

function [filt_img_fft] = filter_with_fft (im_pad, sigma)
  size_1 = size (im_pad, 2);
  size_2 = size (im_pad, 1);

  x1 = linspace (-(size_1-1)/2, (size_1-1)/2, size_1);
  ## make numbers in list always as whole numbers, caused problem with x.5
  ## numbers on even picture sie
  x2 = linspace (-(size_2-1)/2, (size_2-1)/2, size_2);
  if(mod (size_1, 2) == 0)
    x1 -= 0.5;
  endif
  if(mod (size_2, 2) == 0)
    x2 -= 0.5;
  endif

  ## lines
  fil_x1 = exp (-(x1.^2) ./ (2*sigma(2)^2));
  fil_x1 /= sum (fil_x1);

  ## columns
  fil_x2 = exp (-(x2.^2) ./ (2*sigma(1)^2))';
  fil_x2 /= sum (fil_x2);

  fil1_fft = fft (fil_x1); # lines
  fil2_fft = fft (fil_x2); # lines

  im_fft_1 = fft (im_pad, [], 2);
  im1_fft = im_fft_1 .* fil1_fft;
  im1 = ifft (im1_fft, [], 2);
  im1 = ifftshift (im1, 2);

  im_fft_2 = fft (im1, [], 1);
  filt_img_fft = im_fft_2 .* fil2_fft;
  filt_img_fft = ifft (filt_img_fft, [], 1);
  filt_img_fft = ifftshift (filt_img_fft, 1);
  filt_img_fft = real (filt_img_fft);
endfunction

## Start of help functions:
function res = isodd(value)
  res = all ((mod (value, 2) == 1));
endfunction

function [sigma, padding, filter_size, filter_domain] = handle_optional_input (
                                         optional_arguments)
  num_of_option_arg = length (optional_arguments);
  sigma_is_given = isodd (num_of_option_arg);
  name_value_is_given = num_of_option_arg > 1;
  sigma = get_sigma (sigma_is_given, optional_arguments);
  [padding, filter_size, filter_domain] = get_name_value_pairs (sigma_is_given,
                                                         name_value_is_given,
                                                         optional_arguments,
                                                         sigma);
endfunction

function sigma = get_sigma (sigma_is_given, optional_arguments)
  sigma = 0.5;
  if(sigma_is_given)
    sigma = optional_arguments{1};
    if(any (sigma < 0 ) || any (! isreal (sigma)))
      ## Must be a positive real numeric
      error ("imgaussfilt: sigma has to be a positive real numeric");
    endif
    if(! isscalar (sigma))
      dim = size (sigma);
      if((dim(1) + dim(2)) > 3) # Does the given vector have the right format?
        error (["imgaussfilt: sigma must be scalar or vector ", ...
              "with two values"]);
      endif
    endif
  endif
  if isscalar (sigma)
    sigma = [sigma, sigma];
  endif
endfunction

function [padding, filter_size, filter_domain] = get_name_value_pairs (
                                                  sigma_is_given,
                                                  name_value_is_given,
                                                  optional_arguments,
                                                  sigma)
  padding_options = {"replicate", "circular", "symmetric"};
  filter_domain_options = {"auto", "frequency", "spatial"};
  padding = "replicate";
  index_first_name = 1 + double (sigma_is_given);
  filter_size = 2 * ceil (2 * sigma) + 1;
  filter_domain = "auto";
  if(name_value_is_given)
  ## Check what kind of name value pair is given and test correctness of input
    for idx = (index_first_name:2:length(optional_arguments))
      name = optional_arguments{idx};
      value = optional_arguments{idx+1};
      if ! ischar (name)
        error ("imgaussfilt: the name value must be string")
      endif
      if(strcmpi (name, "FilterSize"))
        filter_size = value;
        if(! isodd (filter_size) || any (filter_size < 0) ||
          any (filter_size != round (filter_size)))
            error ("imgaussfilt: filter_size has to be an odd, positive integer");
        endif
          if(! isscalar (filter_size))
            dim = size (filter_size);
            if((dim(1) + dim(2)) > 3) # Does the given vector have the right format?
              error (["imgaussfilt: filter_size musst be scalar or vector ", ...
                "with two values"]);
            endif
          else
            filter_size = [filter_size, filter_size];
          endif
      elseif(strcmpi (name, "padding"))
        if(isnumeric (value) || any (strcmpi (padding_options, value)))
            padding = value;
        else
          error ("imgaussfilt: padding option must be 'replicate', 'circular' \
                  'symmetric' or a numeric scalar")
        endif
      elseif(strcmpi (name, "filterDomain"))
        if(! any (strcmpi (filter_domain_options, value)))
          error ("imgaussfilt: filterDomain must be either 'auto', 'frequency' \
                  or 'spatial'");
        endif
        filter_domain = value;
      else
        error (["imgaussfilt: cannot handle option '", name,"'"]);
      endif
    endfor
  endif
endfunction

function [fil1, fil2] = create_gaussfilter (filter_size, sigma)
  fil1 = gauss (sigma(2), filter_size(2));
  fil2 = gauss (sigma(1), filter_size(1))';
  fil1 /= sum (fil1);
  fil2 /= sum (fil2);

endfunction

function retval = gauss(sigma, filter_size)
  x = linspace (-(filter_size-1) / 2, (filter_size-1) / 2, filter_size );
  retval = exp (-(x.^2) / (2 * sigma^2));
endfunction


## Just img test, correct Syntax
%!assert (imgaussfilt(ones (5) * 9));
%!assert (isa (imgaussfilt (uint8  (ones (5))), "uint8"));
%!assert (isa (imgaussfilt (uint16 (ones (5))), "uint16"));
%!assert (isa (imgaussfilt (uint32 (ones (5))), "uint32"));
%!assert (isa (imgaussfilt (uint64 (ones (5))), "uint64"));
%!assert (isa (imgaussfilt (int8   (ones (5))), "int8"));
%!assert (isa (imgaussfilt (int16  (ones (5))), "int16"));
%!assert (isa (imgaussfilt (int32  (ones (5))), "int32"));
%!assert (isa (imgaussfilt (single (ones (5))), "single"));
%!assert (isa (imgaussfilt (double (ones (5))), "double"));

## illegal datatypes for img
%!error (imgaussfilt (true (5)));
%!error (imgaussfilt (5i+9));
%!error (imgaussfilt ({"sdg","sdgsd"}));
%!error (imgaussfilt ("sdjgkhsdkl"));
%!error (imgaussfilt (struct("x", "34", "y", "67")))

## just img test, illegal syntax
%!error (imgaussfilt ());
%!error (imgaussfilt ("asdf"));

% test sigma:
%!assert(imgaussfilt(ones (5), 6));
%!assert(imgaussfilt(ones (5), 1.7));
%!assert (imgaussfilt (ones (5), [1, 4]));
%!error(imgaussfilt(ones (5), -0.5));
%!error (imgaussfilt (ones (3), "asdf"));
%!error (imgaussfilt (ones (3), [3,5,6]));
%!error (imgaussfilt (ones (3), [3,-5]));
%!error (imgaussfilt (ones (3), [-3, 4]));
%!error (imgaussfilt (ones (3), [-3, -4]));

## tests for padding, valid input
%!assert (imgaussfilt (ones (5), "padding", "circular"));
%!assert (imgaussfilt (ones (5), "padding", "symmetric"));
%!assert (imgaussfilt (ones (3), "padding", "replicate"));
%!assert (imgaussfilt (ones (3), "Padding", "Replicate"));
%!assert (imgaussfilt (ones (3), "Padding", 5));

## tests for padding, invalid input
%!error (imgaussfilt (ones (3),  "circular"));
%!error (imgaussfilt (ones (3),  "symmetric", "padding"));
%!error (imgaussfilt (ones (3),  "padding"));
%!error (imgaussfilt (ones (3),  "padding", "ciircular"));
%!error (imgaussfilt (ones (3),  "padding", [2, 3]));

%!error(imgaussfilt(ones (5), 5i));

% test filter size syntax:
%!assert (imgaussfilt (ones (5), "filtersize", 3));
%!assert (imgaussfilt (ones (5), "FilterSize", [5, 7]));
%!assert (imgaussfilt (ones (5), "FilterSize", [5, 3]'));
%!error (imgaussfilt (ones (5), "filter", 3));
%!error (imgaussfilt (ones (5), "filtersize", 4));
%!error (imgaussfilt (ones (5), "filtersize", 5.5));
%!error (imgaussfilt (ones (5), "filterSize", [5, 2]));
%!error (imgaussfilt (ones (5), "filterSize", [5, 2]'));
%!error (imgaussfilt (ones (5), "filtersize", [5, 7.5]));
%!error (imgaussfilt (ones (5), "filtersize", [5, 7.5]'));

% test padding syntaxes:
%!assert (imgaussfilt (ones (5), "padding", "replicate"));
%!assert (imgaussfilt (ones (5), "padding", "circular"));
%!assert (imgaussfilt (ones (5), "padding", "symmetric"));
%!assert (imgaussfilt (ones (5), "padding", 5));

% test Filter domain:
%!assert (imgaussfilt (ones (5), "FilterDomain", "auto"));
%!assert (imgaussfilt (ones (5), "FilterDomain", "frequency"));
%!assert (imgaussfilt (ones (5), "FilterDomain", "spatial"));
%!error (imgaussfilt (ones (5), "FilterDomain", "asdf"));
%!error (imgaussfilt (ones (5), "FilterDomain", 4));

%!test
%! input = [1, 1, 1; 10, 10, 10; 100, 100, 100];
%! expected = [12.5028   12.5028   12.5028
%!             18.6271   18.6271   18.6271
%!             79.8702   79.8702   79.8702];
%! output = imgaussfilt (input, "padding", "circular");
%! assert (output, expected, 0.0001);

%!test
%! input = [1, 1, 1; 10, 10, 10; 100, 100, 100];
%! expected = [1.9586    1.9586    1.9586
%!             18.6271   18.6271   18.6271
%!             90.4144   90.4144   90.4144];
%! output = imgaussfilt (input, "padding", "replicate");
%! assert (output, expected, 0.0001);

%!test
%! input = [1 1 1 1 1 1
%!          1 2 2 2 2 1;
%!          1 2 2 2 2 1;
%!          1 2 2 2 2 1;
%!          1 2 2 2 2 1;
%!          1 1 1 1 1 1];
%! expected = [1.0114    1.0953    1.1067    1.1067    1.0953    1.0114
%!             1.0953    1.7980    1.8930    1.8930    1.7980    1.0953
%!             1.1067    1.8930    1.9995    1.9995    1.8930    1.1067
%!             1.1067    1.8930    1.9995    1.9995    1.8930    1.1067
%!             1.0953    1.7980    1.8930    1.8930    1.7980    1.0953
%!             1.0114    1.0953    1.1067    1.1067    1.0953    1.0114];
%! output = imgaussfilt (input, "filterSize", 5, "padding", "replicate");
%! assert (output, expected, 0.0001);

%!test
%! input = [1 1 1 1 1 1
%!          1 2 2 2 2 1;
%!          1 2 2 2 2 1;
%!          1 2 2 2 2 1;
%!          1 2 2 2 2 1;
%!          1 1 1 1 1 1];
%! expected = [1.0114    1.0956    1.1070    1.1070    1.0956    1.0114
%!             1.0956    1.7980    1.8930    1.8930    1.7980    1.0956
%!             1.1070    1.8930    1.9995    1.9995    1.8930    1.1070
%!             1.1070    1.8930    1.9995    1.9995    1.8930    1.1070
%!             1.0956    1.7980    1.8930    1.8930    1.7980    1.0956
%!             1.0114    1.0956    1.1070    1.1070    1.0956    1.0114];
%! output = imgaussfilt (input, "filterSize", 5, "padding", "symmetric");
%! assert (output, expected, 0.0001);

## test for 4 dim image:
%!test
%! input = zeros(3,3,3,3);
%! input (2,2,:,:) = 9;
%! output = imgaussfilt (input);
%! expected = ones (3,3,3,3);
%! assert (size(output), size(expected), eps);

## test for 4 dim image, channels are independent
%!test
%! a1 = ones (5);
%! a2 = ones (5) * 2;
%! a3 = ones (5) * 3;
%! a4 = ones (5) * 4;
%! im = cat (4, a1, a2, a3, a4);
%! expected = im;
%! output = imgaussfilt (im);
%! assert (output, expected, 0.0001);

%!test
%! input = zeros(5,7);
%! input(3,4) = 1;
%! expected = [ -0.0000 0.0001 0.0006 0.0011 0.0006 0.0001 -0.0000
%!               0.0000 0.0062 0.0397 0.0736 0.0397 0.0062 0.0000
%!               0      0.0250 0.1593 0.2953 0.1593 0.0250 -0.0000
%!               0      0.0062 0.0397 0.0736 0.0397 0.0062 -0.0000
%!              -0.0000 0.0001 0.0006 0.0011 0.0006 0.0001 -0.0000 ];
%! output = imgaussfilt(input, [0.6,0.9], "filterDomain", "frequency");
%! assert (output, expected, 0.01);
## test paddings for fft
%!test
%! input = zeros(8);
%! input(6,4) = 1;
%! input(6,5) = 1;
%! input(7,4) = 2;
%! input(7,5) = 2;
%! expected_replicate = [-0.0000 -0.0000  0.0000  0.0000  0.0000  0.0000  0.0000  0.0000
%!                        0.0000  0.0000  0.0000  0.0000  0.0000  0.0000  0.0000  0.0000
%!                        0.0000  0.0000 -0.0000  0.0000  0.0000  0.0000  0.0000  0.0000
%!                        0.0000  0.0030  0.0163  0.0352  0.0352  0.0163  0.0030  0.0000
%!                        0.0000  0.0163  0.0892  0.1932  0.1932  0.0892  0.0163  0.0000
%!                        0.0000  0.0352  0.1932  0.4184  0.4184  0.1932  0.0352  0.0000
%!                             0  0.0352  0.1932  0.4184  0.4184  0.1932  0.0352       0
%!                       -0.0000  0.0192  0.1055  0.2284  0.2284  0.1055  0.0192  0.0000];
%! expected_circular = [-0.0000  0.0030  0.0163  0.0352  0.0352  0.0163  0.0030  0.0000
%!                       0.0000 -0.0000 -0.0000  0.0000  0.0000  0.0000  0.0000  0.0000
%!                       0.0000  0.0000 -0.0000  0.0000  0.0000  0.0000  0.0000  0.0000
%!                       0.0000  0.0030  0.0163  0.0352  0.0352  0.0163  0.0030  0.0000
%!                       0.0000  0.0163  0.0892  0.1932  0.1932  0.0892  0.0163  0.0000
%!                            0  0.0352  0.1932  0.4184  0.4184  0.1932  0.0352  0.0000
%!                       0.0000  0.0352  0.1932  0.4184  0.4184  0.1932  0.0352  0.0000
%!                       0.0000  0.0163  0.0892  0.1932  0.1932  0.0892  0.0163  0.0000];
%! expected_symmetric = [-0.0000 -0.0000 -0.0000  0.0000  0.0000 -0.0000 -0.0000 -0.0000
%!                        0.0000  0.0000  0.0000  0.0000  0.0000  0.0000  0.0000  0.0000
%!                        0.0000  0.0000 -0.0000  0.0000  0.0000  0.0000  0.0000  0.0000
%!                        0.0000  0.0030  0.0163  0.0352  0.0352  0.0163  0.0030  0.0000
%!                             0  0.0163  0.0892  0.1932  0.1932  0.0892  0.0163       0
%!                        0.0000  0.0352  0.1932  0.4184  0.4184  0.1932  0.0352       0
%!                             0  0.0352  0.1932  0.4184  0.4184  0.1932  0.0352       0
%!                        0.0000  0.0163  0.0892  0.1932  0.1932  0.0892  0.0163  0.0000];
%! output_symmetric = imgaussfilt(input, 1, "filterDomain", "frequency", "padding", "symmetric");
%! output_circular = imgaussfilt(input, 1, "filterDomain", "frequency", "padding", "circular");
%! output_replicate = imgaussfilt(input, 1, "filterDomain", "frequency", "padding", "replicate");
%! assert (output_symmetric, expected_symmetric, 0.3);
%! assert (output_circular, expected_circular, 0.3);
%! assert (output_replicate, expected_replicate, 0.3);
% Expected outputs are values from Matlab(there's some tolerance)

## test orientation for different sigma values in two axis
%!test
%! im = zeros (11);
%! im(6,6) = 1;
%! out = imgaussfilt (im, [2, 0.5]);
%! assert (sum (out(6,:)), 0.2042, 0.0001);
%! assert (sum (out(:,6)), 0.7870, 0.0001);

