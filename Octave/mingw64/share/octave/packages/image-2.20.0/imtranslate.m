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
## @deftypefn {Function File} @var{trans_img} = imtranslate (@var{img}, @var{translation})
## @deftypefnx {Function File} @var{trans_img} = imtranslate (@var{img}, @var{translation}, @var{method})
## @deftypefnx {Function File} @var{trans_img} = imtranslate (@var{img}, @var{translation}, @var{method}, Name, Value, @dots{})
## @deftypefnx {Function File} @var{trans_img} = imtranslate (@var{img}, @var{input_ref}, @var{translation})
## @deftypefnx {Function File} @var{trans_img} = imtranslate (@var{img}, @var{input_ref}, @var{translation}, @var{method})
## @deftypefnx {Function File} @var{trans_img} = imtranslate (@var{img}, @var{input_ref}, @var{translation}, @var{method}, Name, Value, @dots{})
## @deftypefnx {Function File} [@var{trans_img}, @var{output_ref}] = imtranslate (@var{img}, @var{translation})
## @deftypefnx {Function File} [@var{trans_img}, @var{output_ref}] = imtranslate (@var{img}, @var{translation}, @var{method})
## @deftypefnx {Function File} [@var{trans_img}, @var{output_ref}] = imtranslate (@var{img}, @var{translation}, @var{method}, Name, Value, @dots{})
## @deftypefnx {Function File} [@var{trans_img}, @var{output_ref}] = imtranslate (@var{img}, @var{input_ref}, @var{translation})
## @deftypefnx {Function File} [@var{trans_img}, @var{output_ref}] = imtranslate (@var{img}, @var{input_ref}, @var{translation}, @var{method})
## @deftypefnx {Function File} [@var{trans_img}, @var{output_ref}] = imtranslate (@var{img}, @var{input_ref}, @var{translation}, @var{method}, Name, Value, @dots{})
##
## Translate an image spatially by a specified 2D vector.
##
## This function shifts the input image @var{img} by the amount specified in @var{translation},
## using the specified interpolation method. It supports grayscale, RGB images,
## or even multi-channel images.
## Image type can int8, uint8, int16, uint16, int32, uint32, single or double.
##
## You can optionally specify spatial referencing objects to define the
## coordinate system of the input and output images.
##
## @strong{Note}
## imtranslate does not support 3D translation of 3D volumes.
##
## @strong{Inputs}
##
## @table @var
## @item img
## Input image. Can be:
## @itemize
## @item Grayscale (MxN)
## @item RGB (MxNx3)
## @item multi-channel image (MxNxC)
## @end itemize
##
## @item translation
## A numeric 2D vector specifying the translation in pixels.
## If spatial referencing is used, translation is interpreted in world units.
##
## @item method
## (Optional) Interpolation method. One of:
## @code{"nearest"}, @code{"linear"}/@code{"bilinear"}, @code{"cubic"}/@code{"bicubic"}.
## Default is @code{"linear"}.
##
## @item input_ref
## (Optional) An imref2d object specifying the spatial referencing of the input image.
## This object defines the mapping between pixel coordinates and world coordinates for the input image.
## Image size in input_ref shoule be the same as the size of img
## If omitted, a default imref2d object is created for the image size.
##
## @item param1, value1, ...
## (Optional) Name-value pairs:
##
## @table @code
## @item "FillValues"
## Scalar or array specifying fill values for pixels outside the input image domain.
## Default is 0.
## FillValues can be a scalar, or in the case of MxNXC image a C-dimensional vector
##
## @item "OutputView"
## String specifying how to determine the size and limits of the output image.
## Options:
## @code{"same"} Output image is the same size as input.
## @code{"full"} Output image includes all translated pixels.
##
## @end table
## @end table
##
## @strong{Outputs}
##
## @table @var
## @item trans_img
## Translated output image. Same class as input @var{img}.
##
## @item output_ref
## (Optional) An imref2d object specifying the spatial referencing of the output image.
## This object describes the world limits, pixel extents, and image size of the output image,
## allowing for accurate mapping between pixel and world coordinates after translation.
## @end table
##
## @strong{Examples}
##
## @example
## I = phantom();
## J = imtranslate(I, [25 10]);
## imshow(J);
## @end example
##
## @example
## input_ref = imref2d(size(I), [0.5 100.5], [0.5 100.5]);  # Define input spatial reference
## J = imtranslate(I, input_ref, [5 5], "bilinear", "OutputView", "same");
## imshow(J);
## @end example
##
## @strong{Algorithm}
##
## This function uses imtransform to calculate the translated image
##
## @seealso{imtransform, imresize, imrotate, imref2d}
## @end deftypefn

function [img_out, output_ref] = imtranslate(img, varargin)

    if (nargin < 2)
        print_usage();
    endif
    if (!isimage(img))
      error("imtranslate: The input img must be a valid image (grayscale or RGB).");
    endif
    if ! all(isfinite(img(:)))
      error("imtranslate: The input img must be a finite value image (grayscale or RGB).");
    endif

    img_class = class(img);
    [translation, input_ref, method, output_view, fill_val] = ...
        parse_imtranslate_inputs(img, varargin{:});
    dx = translation(1);
    dy = translation(2);
    # Handle spatial referencing
    if isempty(input_ref)
        output_ref = imref2d(size(img));
    else
        if any(input_ref.ImageSize != size(img, 1:2))
            error("imtranslate: image size of input_ref must match img size.");
        endif
        output_ref = input_ref;
        dx = dx / input_ref.PixelExtentInWorldX;
        dy = dy / input_ref.PixelExtentInWorldY;
    endif
    # Handle OutputView logic
    [img, output_ref] = handleOutputView(img, input_ref, output_ref, dx, dy, fill_val, output_view);
    # Integer translation optimization
    if (round(dx) == dx && round(dy) == dy)
        img_out = translate_int(img, dx, dy, fill_val);
    else
        # Non-integer translation using affine transformation
        T = [1 0 0; 0 1 0; dx, dy, 1];
        tform = maketform("affine", T);
        if !isa(img, "double")
            img = double(img);
        endif
        img_out = imtransform(img, tform, method, ...
            "XData", [1 size(img,2)], "YData", [1 size(img,1)], ...
            "FillValues", fill_val);
        img_out = cast(img_out, img_class); # turn result back to original datatype
    endif
endfunction

function [translation, input_ref, method, output_view, fill_val] = ...
    parse_imtranslate_inputs(img, varargin)
    # parse_imtranslate_inputs Parse and validate inputs for imtranslate.
    if isempty(varargin)
        error("imtranslate: Translation vector is required.");
    endif
    ind = 1;
    input_ref = [];
    method = "bilinear";
    if isa(varargin{1}, "imref2d")
        if numel(varargin) == 1
            error("imtranslate: Not enough inputs. Translation vector required after spatial reference.");
        endif
        input_ref = varargin{1};
        ind = 2;
    endif
    if (numel(varargin) > 1 && isa(varargin{2}, "imref2d"))
        error("imtranslate: ref_input should be the 2nd input");
    endif
    translation = varargin{ind};
    if ! (isnumeric(translation) && numel(translation) == 2 && isreal(translation))
        error("imtranslate: Translation must be a real numeric 2-element vector.");
    endif
    if (numel(varargin) > ind)
        try
            method = validatestring(varargin{ind+1}, {"nearest", "linear", "cubic", ...
                "bilinear", "bicubic"});
            if strcmp(method, "linear") || strcmp(method, "cubic")
                # imtransform uses bilinear and bicubic
                method = ["bi" method];
            endif
            ind = ind + 1;
        end_try_catch
    endif
    parser = inputParser;
    parser.FunctionName = "imtranslate";
    parser.addParameter("OutputView", "same", @(x) ismember(x, {"same", "full"}));
    parser.addParameter("FillValues", 0, @(x) isnumeric(x) && isreal(x));
    parser.parse(varargin{ind+1:end});
    args = parser.Results;
    output_view = args.OutputView;
    if ! isscalar(args.FillValues)
        if ndims(args.FillValues) > 2
            error("imtranslate: FillValues should be a scalar or a vector.");
        elseif ndims(args.FillValues) == 2 && min(size(args.FillValues)) > 1
            error("imtranslate: FillValues should be a scalar or a vector.");
        endif
        if size(img, 3) == 1
            error("imtranslate: For a 2D image, FillValues should be a scalar.");
        elseif size(img, 3) != max(size(args.FillValues))
            error("imtranslate: For a multi-channel image, FillValues should be a scalar or match the 3rd dimension.");
        endif
    endif
    fill_val = args.FillValues;
endfunction

function [img, output_ref] = handleOutputView(img, input_ref, output_ref, dx, dy, fill_val, output_view)
    # handleOutputView Handles OutputView logic and padding for "full" option.
    if strcmp(output_view, "full")
        [img, height, width] = pad_array(img, dx, dy, fill_val);
        if isempty(input_ref)
            output_ref = imref2d(size(img));
            if (dx < 0) || (dy < 0)
                XWorldLimits = output_ref.XWorldLimits + min(floor(dx), 0);
                YWorldLimits = output_ref.YWorldLimits + min(floor(dy), 0);
                output_ref = imref2d([height, width], XWorldLimits, YWorldLimits);
            endif
        else
            output_ref = imref2d([height, width], input_ref.PixelExtentInWorldX, input_ref.PixelExtentInWorldY);
            if dx > 0
                output_ref.XWorldLimits = output_ref.XWorldLimits - output_ref.XWorldLimits(1) + input_ref.XWorldLimits(1);
            else
                output_ref.XWorldLimits = output_ref.XWorldLimits - output_ref.XWorldLimits(2) + input_ref.XWorldLimits(2);
            endif
            if dy > 0
                output_ref.YWorldLimits = output_ref.YWorldLimits - output_ref.YWorldLimits(1) + input_ref.YWorldLimits(1);
            else
                output_ref.YWorldLimits = output_ref.YWorldLimits - output_ref.YWorldLimits(2) + input_ref.YWorldLimits(2);
            endif
        endif
    endif
endfunction

function img_out = translate_int(img, dx, dy, fill_val)
    # translate_int Performs integer translation using array slicing.
    if (dx == 0 && dy == 0)
        img_out = img;
        return;
    endif
    if isscalar(fill_val)
        img_out = fill_val * ones(size(img), class(img));
    else
        img_out = ones(size(img), class(img));
        for layer = 1:length(fill_val)
            img_out(:, :, layer) = fill_val(layer);
        endfor
    endif
    rows = size(img, 1);
    cols = size(img, 2);
    # Calculate source and destination indices
    src_row_start = max(1, 1 - dy);
    src_row_end = min(rows, rows - dy);
    dst_row_start = max(1, 1 + dy);
    dst_row_end = min(rows, rows + dy);
    src_col_start = max(1, 1 - dx);
    src_col_end = min(cols, cols - dx);
    dst_col_start = max(1, 1 + dx);
    dst_col_end = min(cols, cols + dx);
    img_out(dst_row_start:dst_row_end, dst_col_start:dst_col_end, :) = ...
        img(src_row_start:src_row_end, src_col_start:src_col_end, :);
endfunction

function [img, height, width] = pad_array(img, dx, dy, fill_val)
    # pad_array Pad the image for "full" output view.
    # Inputs:
    #   img: HxWxC (C can be 1 or 3)
    #   dx, dy: translation components affecting where padding is added
    #   fill_val: scalar (e.g., 0) or 1xC vector (e.g., [r g b] for RGB)
    # Behavior:
    #   - If dx > 0: pad columns on the right ("post"), else on the left ("pre")
    #   - If dy > 0: pad rows on the bottom ("post"), else on the top ("pre")
    pad_cols = ceil(abs(dx));
    pad_rows = ceil(abs(dy));
    width = size(img, 2) + pad_cols;
    height = size(img, 1) + pad_rows;
    if pad_cols == 0 && pad_rows == 0
        return;
    endif
    if isscalar(fill_val)
        if dx > 0
            img = padarray(img, [0, pad_cols], fill_val, "post");
        elseif dx < 0
            img = padarray(img, [0, pad_cols], fill_val, "pre");
        endif
        if dy > 0
            img = padarray(img, [pad_rows, 0], fill_val, "post");
        elseif dy < 0
            img = padarray(img, [pad_rows, 0], fill_val, "pre");
        endif
    else
        C = size(img, 3);
        assert(isvector(fill_val) && numel(fill_val) == C, ...
            "pad_array: fill_val must be scalar or a 1x#d vector to match the number of channels.", C);
        if ! isa(fill_val, class(img))
            fill_val = cast(fill_val, class(img));
        endif
        color = reshape(fill_val, [1 1 C]);
        canvas = repmat(color, height, width);
        left_offset = (dx > 0) * 0 + (dx <= 0) * pad_cols;
        top_offset = (dy > 0) * 0 + (dy <= 0) * pad_rows;
        r = top_offset + (1:size(img, 1));
        c = left_offset + (1:size(img, 2));
        canvas(r, c, :) = img;
        img = canvas;
    endif
endfunction

%! ##############################################################################
%! ## BASIC TRANSLATION TESTS - Grayscale Images
%! ##############################################################################
%!
%!test
%! ## Test zero translation (identity)
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0]);
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0]);
%! assert (result, uint8([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0]);
%! assert (result, uint8([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2]);
%! assert (result, uint8([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2]);
%! assert (result, uint8([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2]);
%! assert (result, uint8([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1]);
%! assert (result, uint8([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2]);
%! assert (result, uint8([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2]);
%! assert (result, uint8([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7]);
%! assert (result, uint8([0 0 0 0; 0 1 1 1; 2 3 4 5; 4 7 8 9]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4]);
%! assert (result, uint8([0 0 0 0; 1 2 2 0; 5 6 4 0; 9 10 7 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = uint8(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20]);
%! assert (result, uint8(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ##############################################################################
%! ## IMAGE TYPE TESTS - All numeric types
%! ##############################################################################
%!
%! ## int8
%!
%!test
%! ## Test zero translation (identity)
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0]);
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0]);
%! assert (result, int8([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0]);
%! assert (result, int8([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2]);
%! assert (result, int8([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2]);
%! assert (result, int8([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2]);
%! assert (result, int8([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1]);
%! assert (result, int8([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2]);
%! assert (result, int8([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2]);
%! assert (result, int8([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7]);
%! assert (result, int8([0 0 0 0; 0 1 1 1; 2 3 4 5; 4 7 8 9]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4]);
%! assert (result, int8([0 0 0 0; 1 2 2 0; 5 6 4 0; 9 10 7 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = int8(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20]);
%! assert (result, int8(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## uint16
%!
%!test
%! ## Test zero translation (identity)
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0]);
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0]);
%! assert (result, uint16([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0]);
%! assert (result, uint16([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2]);
%! assert (result, uint16([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2]);
%! assert (result, uint16([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2]);
%! assert (result, uint16([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1]);
%! assert (result, uint16([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2]);
%! assert (result, uint16([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2]);
%! assert (result, uint16([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7]);
%! assert (result, uint16([0 0 0 0; 0 1 1 1; 2 3 4 5; 4 7 8 9]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4]);
%! assert (result, uint16([0 0 0 0; 1 2 2 0; 5 6 4 0; 9 10 7 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = uint16(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20]);
%! assert (result, uint16(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## int16
%!
%!test
%! ## Test zero translation (identity)
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0]);
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0]);
%! assert (result, int16([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0]);
%! assert (result, int16([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2]);
%! assert (result, int16([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2]);
%! assert (result, int16([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2]);
%! assert (result, int16([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1]);
%! assert (result, int16([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2]);
%! assert (result, int16([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2]);
%! assert (result, int16([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7]);
%! assert (result, int16([0 0 0 0; 0 1 1 1; 2 3 4 5; 4 7 8 9]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4]);
%! assert (result, int16([0 0 0 0; 1 2 2 0; 5 6 4 0; 9 10 7 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = int16(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20]);
%! assert (result, int16(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## uint32
%!
%!test
%! ## Test zero translation (identity)
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0]);
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0]);
%! assert (result, uint32([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0]);
%! assert (result, uint32([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2]);
%! assert (result, uint32([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2]);
%! assert (result, uint32([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2]);
%! assert (result, uint32([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1]);
%! assert (result, uint32([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2]);
%! assert (result, uint32([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2]);
%! assert (result, uint32([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7]);
%! assert (result, uint32([0 0 0 0; 0 1 1 1; 2 3 4 5; 4 7 8 9]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4]);
%! assert (result, uint32([0 0 0 0; 1 2 2 0; 5 6 4 0; 9 10 7 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = uint32(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20]);
%! assert (result, uint32(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## int32
%!
%!test
%! ## Test zero translation (identity)
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0]);
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0]);
%! assert (result, int32([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0]);
%! assert (result, int32([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2]);
%! assert (result, int32([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2]);
%! assert (result, int32([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2]);
%! assert (result, int32([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1]);
%! assert (result, int32([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2]);
%! assert (result, int32([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2]);
%! assert (result, int32([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7]);
%! assert (result, int32([0 0 0 0; 0 1 1 1; 2 3 4 5; 4 7 8 9]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4]);
%! assert (result, int32([0 0 0 0; 1 2 2 0; 5 6 4 0; 9 10 7 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = int32(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20]);
%! assert (result, int32(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## single
%!
%!test
%! ## Test zero translation (identity)
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0]);
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0]);
%! assert (result, single([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0]);
%! assert (result, single([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2]);
%! assert (result, single([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2]);
%! assert (result, single([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2]);
%! assert (result, single([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1]);
%! assert (result, single([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2]);
%! assert (result, single([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2]);
%! assert (result, single([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7]);
%! assert (result, single([0 0 0 0; 0.21 0.51 0.81 1.11; 1.54 2.9 3.9 4.9; 4.34 6.9 7.9 8.9]), 1e-6)
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4]);
%! assert (result, single([0 0 0 0; 1.38 1.98 1.68 0; 4.7 5.7 4.48 0; 8.7 9.7 7.28 0]), 1e-6)
%! assert (size(result), size(img));
%!
%!
%!test
%! ## Test large translation
%! img = single(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20]);
%! assert (result, single(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## double
%!
%!test
%! ## Test zero translation (identity)
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0]);
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0]);
%! assert (result, double([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0]);
%! assert (result, double([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2]);
%! assert (result, double([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2]);
%! assert (result, double([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2]);
%! assert (result, double([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1]);
%! assert (result, double([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2]);
%! assert (result, double([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2]);
%! assert (result, double([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7]);
%! assert (result, double([0 0 0 0; 0.21 0.51 0.81 1.11; 1.54 2.9 3.9 4.9; 4.34 6.9 7.9 8.9]), 4e-15)
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4]);
%! assert (result, double([0 0 0 0; 1.38 1.98 1.68 0; 4.7 5.7 4.48 0; 8.7 9.7 7.28 0]), 4e-15)
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = double(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20]);
%! assert (result, double(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ##############################################################################
%! ## BASIC TRANSLATION TESTS - Using Linear interpolation explicitly
%! ##############################################################################
%!
%!test
%! ## Test zero translation (identity)
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "linear");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "linear");
%! assert (result, uint8([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "linear");
%! assert (result, uint8([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "linear");
%! assert (result, uint8([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "linear");
%! assert (result, uint8([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "linear");
%! assert (result, uint8([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "linear");
%! assert (result, uint8([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "linear");
%! assert (result, uint8([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "linear");
%! assert (result, uint8([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "linear");
%! assert (result, uint8([0 0 0 0; 0 1 1 1; 2 3 4 5; 4 7 8 9]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "linear");
%! assert (result, uint8([0 0 0 0; 1 2 2 0; 5 6 4 0; 9 10 7 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = uint8(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "linear");
%! assert (result, uint8(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## int8
%!
%!test
%! ## Test zero translation (identity)
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "linear");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "linear");
%! assert (result, int8([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "linear");
%! assert (result, int8([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "linear");
%! assert (result, int8([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "linear");
%! assert (result, int8([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "linear");
%! assert (result, int8([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "linear");
%! assert (result, int8([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "linear");
%! assert (result, int8([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "linear");
%! assert (result, int8([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "linear");
%! assert (result, int8([0 0 0 0; 0 1 1 1; 2 3 4 5; 4 7 8 9]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "linear");
%! assert (result, int8([0 0 0 0; 1 2 2 0; 5 6 4 0; 9 10 7 0]))
%! assert (size(result), size(img));
%!test
%!
%! ## Test large translation
%! img = int8(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "linear");
%! assert (result, int8(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## uint16
%!
%!test
%! ## Test zero translation (identity)
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "linear");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "linear");
%! assert (result, uint16([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "linear");
%! assert (result, uint16([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "linear");
%! assert (result, uint16([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "linear");
%! assert (result, uint16([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "linear");
%! assert (result, uint16([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "linear");
%! assert (result, uint16([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "linear");
%! assert (result, uint16([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "linear");
%! assert (result, uint16([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "linear");
%! assert (result, uint16([0 0 0 0; 0 1 1 1; 2 3 4 5; 4 7 8 9]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "linear");
%! assert (result, uint16([0 0 0 0; 1 2 2 0; 5 6 4 0; 9 10 7 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = uint16(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "linear");
%! assert (result, uint16(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## int16
%!
%!test
%! ## Test zero translation (identity)
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "linear");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "linear");
%! assert (result, int16([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "linear");
%! assert (result, int16([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "linear");
%! assert (result, int16([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "linear");
%! assert (result, int16([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "linear");
%! assert (result, int16([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "linear");
%! assert (result, int16([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "linear");
%! assert (result, int16([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "linear");
%! assert (result, int16([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "linear");
%! assert (result, int16([0 0 0 0; 0 1 1 1; 2 3 4 5; 4 7 8 9]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "linear");
%! assert (result, int16([0 0 0 0; 1 2 2 0; 5 6 4 0; 9 10 7 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = int16(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "linear");
%! assert (result, int16(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## uint32
%!
%!test
%! ## Test zero translation (identity)
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "linear");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "linear");
%! assert (result, uint32([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "linear");
%! assert (result, uint32([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "linear");
%! assert (result, uint32([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "linear");
%! assert (result, uint32([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "linear");
%! assert (result, uint32([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "linear");
%! assert (result, uint32([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "linear");
%! assert (result, uint32([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "linear");
%! assert (result, uint32([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "linear");
%! assert (result, uint32([0 0 0 0; 0 1 1 1; 2 3 4 5; 4 7 8 9]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "linear");
%! assert (result, uint32([0 0 0 0; 1 2 2 0; 5 6 4 0; 9 10 7 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = uint32(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "linear");
%! assert (result, uint32(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## int32
%!
%!test
%! ## Test zero translation (identity)
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "linear");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "linear");
%! assert (result, int32([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "linear");
%! assert (result, int32([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "linear");
%! assert (result, int32([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "linear");
%! assert (result, int32([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "linear");
%! assert (result, int32([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "linear");
%! assert (result, int32([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "linear");
%! assert (result, int32([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "linear");
%! assert (result, int32([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "linear");
%! assert (result, int32([0 0 0 0; 0 1 1 1; 2 3 4 5; 4 7 8 9]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "linear");
%! assert (result, int32([0 0 0 0; 1 2 2 0; 5 6 4 0; 9 10 7 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = int32(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "linear");
%! assert (result, int32(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## single
%!
%!test
%! ## Test zero translation (identity)
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "linear");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "linear");
%! assert (result, single([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "linear");
%! assert (result, single([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "linear");
%! assert (result, single([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "linear");
%! assert (result, single([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "linear");
%! assert (result, single([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "linear");
%! assert (result, single([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "linear");
%! assert (result, single([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "linear");
%! assert (result, single([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "linear");
%! assert (result, single([0 0 0 0; 0.21 0.51 0.81 1.11; 1.54 2.9 3.9 4.9; 4.34 6.9 7.9 8.9]), 1e-6)
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "linear");
%! assert (result, single([0 0 0 0; 1.38 1.98 1.68 0; 4.7 5.7 4.48 0; 8.7 9.7 7.28 0]), 1e-6)
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = single(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "linear");
%! assert (result, single(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## double
%!
%!test
%! ## Test zero translation (identity)
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "linear");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "linear");
%! assert (result, double([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "linear");
%! assert (result, double([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "linear");
%! assert (result, double([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "linear");
%! assert (result, double([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "linear");
%! assert (result, double([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "linear");
%! assert (result, double([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "linear");
%! assert (result, double([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "linear");
%! assert (result, double([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "linear");
%! assert (result, double([0 0 0 0; 0.21 0.51 0.81 1.11; 1.54 2.9 3.9 4.9; 4.34 6.9 7.9 8.9]), 4e-15)
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "linear");
%! assert (result, double([0 0 0 0; 1.38 1.98 1.68 0; 4.7 5.7 4.48 0; 8.7 9.7 7.28 0]), 4e-15)
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = double(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "linear");
%! assert (result, double(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%!
%! ##############################################################################
%! ## BASIC TRANSLATION TESTS - Using nearest interpolation
%! ##############################################################################
%!
%!test
%! ## Test zero translation (identity)
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "nearest");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "nearest");
%! assert (result, uint8([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "nearest");
%! assert (result, uint8([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "nearest");
%! assert (result, uint8([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "nearest");
%! assert (result, uint8([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "nearest");
%! assert (result, uint8([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "nearest");
%! assert (result, uint8([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "nearest");
%! assert (result, uint8([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "nearest");
%! assert (result, uint8([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "nearest");
%! assert (result, uint8([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "nearest");
%! assert (result, uint8([0 0 0 0; 2 3 4 0; 6 7 8 0; 10 11 12 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = uint8(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "nearest");
%! assert (result, uint8(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## int8
%!
%!test
%! ## Test zero translation (identity)
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "nearest");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "nearest");
%! assert (result, int8([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "nearest");
%! assert (result, int8([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "nearest");
%! assert (result, int8([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "nearest");
%! assert (result, int8([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "nearest");
%! assert (result, int8([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "nearest");
%! assert (result, int8([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "nearest");
%! assert (result, int8([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "nearest");
%! assert (result, int8([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "nearest");
%! assert (result, int8([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "nearest");
%! assert (result, int8([0 0 0 0; 2 3 4 0; 6 7 8 0; 10 11 12 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = int8(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "nearest");
%! assert (result, int8(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## uint16
%!
%!test
%! ## Test zero translation (identity)
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "nearest");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "nearest");
%! assert (result, uint16([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "nearest");
%! assert (result, uint16([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "nearest");
%! assert (result, uint16([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "nearest");
%! assert (result, uint16([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "nearest");
%! assert (result, uint16([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "nearest");
%! assert (result, uint16([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "nearest");
%! assert (result, uint16([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "nearest");
%! assert (result, uint16([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "nearest");
%! assert (result, uint16([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "nearest");
%! assert (result, uint16([0 0 0 0; 2 3 4 0; 6 7 8 0; 10 11 12 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = uint16(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "nearest");
%! assert (result, uint16(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## int16
%!
%!test
%! ## Test zero translation (identity)
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "nearest");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "nearest");
%! assert (result, int16([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "nearest");
%! assert (result, int16([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "nearest");
%! assert (result, int16([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "nearest");
%! assert (result, int16([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "nearest");
%! assert (result, int16([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "nearest");
%! assert (result, int16([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "nearest");
%! assert (result, int16([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "nearest");
%! assert (result, int16([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "nearest");
%! assert (result, int16([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "nearest");
%! assert (result, int16([0 0 0 0; 2 3 4 0; 6 7 8 0; 10 11 12 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = int16(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "nearest");
%! assert (result, int16(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## uint32
%!
%!test
%! ## Test zero translation (identity)
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "nearest");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "nearest");
%! assert (result, uint32([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "nearest");
%! assert (result, uint32([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "nearest");
%! assert (result, uint32([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "nearest");
%! assert (result, uint32([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "nearest");
%! assert (result, uint32([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "nearest");
%! assert (result, uint32([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "nearest");
%! assert (result, uint32([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "nearest");
%! assert (result, uint32([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "nearest");
%! assert (result, uint32([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "nearest");
%! assert (result, uint32([0 0 0 0; 2 3 4 0; 6 7 8 0; 10 11 12 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "nearest");
%! assert (result, uint32([0 0 0 0; 2 3 4 0; 6 7 8 0; 10 11 12 0]))
%! assert (size(result), size(img))
%!
%!test
%! ## Test large translation
%! img = uint32(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "nearest");
%! assert (result, uint32(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## int32
%!
%!test
%! ## Test zero translation (identity)
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "nearest");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "nearest");
%! assert (result, int32([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "nearest");
%! assert (result, int32([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "nearest");
%! assert (result, int32([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "nearest");
%! assert (result, int32([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "nearest");
%! assert (result, int32([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "nearest");
%! assert (result, int32([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "nearest");
%! assert (result, int32([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "nearest");
%! assert (result, int32([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "nearest");
%! assert (result, int32([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "nearest");
%! assert (result, int32([0 0 0 0; 2 3 4 0; 6 7 8 0; 10 11 12 0]))
%! assert (size(result), size(img))
%!
%!test
%! ## Test large translation
%! img = int32(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "nearest");
%! assert (result, int32(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## single
%!
%!test
%! ## Test zero translation (identity)
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "nearest");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "nearest");
%! assert (result, single([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "nearest");
%! assert (result, single([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "nearest");
%! assert (result, single([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "nearest");
%! assert (result, single([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "nearest");
%! assert (result, single([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "nearest");
%! assert (result, single([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "nearest");
%! assert (result, single([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "nearest");
%! assert (result, single([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "nearest");
%! assert (result, single([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "nearest");
%! assert (result, single([0 0 0 0; 2 3 4 0; 6 7 8 0; 10 11 12 0]))
%! assert (size(result), size(img))
%!
%!test
%! ## Test large translation
%! img = single(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "nearest");
%! assert (result, single(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## double
%!
%!test
%! ## Test zero translation (identity)
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "nearest");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "nearest");
%! assert (result, double([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "nearest");
%! assert (result, double([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "nearest");
%! assert (result, double([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "nearest");
%! assert (result, double([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "nearest");
%! assert (result, double([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "nearest");
%! assert (result, double([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "nearest");
%! assert (result, double([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "nearest");
%! assert (result, double([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "nearest");
%! assert (result, double([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "nearest");
%! assert (result, double([0 0 0 0; 2 3 4 0; 6 7 8 0; 10 11 12 0]))
%! assert (size(result), size(img))
%!
%!test
%! ## Test large translation
%! img = double(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "nearest");
%! assert (result, double(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%!
%! ##############################################################################
%! ## BASIC TRANSLATION TESTS - Using cubic interpolation
%! ##############################################################################
%!
%!
%!test
%! ## Test zero translation (identity)
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "cubic");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "cubic");
%! assert (result, uint8([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "cubic");
%! assert (result, uint8([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "cubic");
%! assert (result, uint8([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "cubic");
%! assert (result, uint8([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "cubic");
%! assert (result, uint8([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "cubic");
%! assert (result, uint8([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "cubic");
%! assert (result, uint8([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "cubic");
%! assert (result, uint8([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "cubic");
%! assert (result, uint8([0 0 0 0; 0 0 1 1; 1 3 4 5; 5 7 8 10]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "cubic");
%! assert (result, uint8([0 0 0 0; 1 2 2 0; 5 6 5 0; 9 10 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = uint8(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "cubic");
%! assert (result, uint8(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## int8
%!
%!test
%! ## Test zero translation (identity)
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "cubic");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "cubic");
%! assert (result, int8([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "cubic");
%! assert (result, int8([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "cubic");
%! assert (result, int8([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "cubic");
%! assert (result, int8([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "cubic");
%! assert (result, int8([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "cubic");
%! assert (result, int8([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "cubic");
%! assert (result, int8([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "cubic");
%! assert (result, int8([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "cubic");
%! assert (result, int8([0 0 0 0; 0 0 1 1; 1 3 4 5; 5 7 8 10]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "cubic");
%! assert (result, int8([0 0 0 0; 1 2 2 0; 5 6 5 0; 9 10 8 -1]))
%! assert (size(result), size(img));
%!test
%!
%! ## Test large translation
%! img = int8(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "cubic");
%! assert (result, int8(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## uint16
%!
%!test
%! ## Test zero translation (identity)
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "cubic");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "cubic");
%! assert (result, uint16([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "cubic");
%! assert (result, uint16([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "cubic");
%! assert (result, uint16([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "cubic");
%! assert (result, uint16([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "cubic");
%! assert (result, uint16([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "cubic");
%! assert (result, uint16([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "cubic");
%! assert (result, uint16([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "cubic");
%! assert (result, uint16([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "cubic");
%! assert (result, uint16([0 0 0 0; 0 0 1 1; 1 3 4 5; 5 7 8 10]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "cubic");
%! assert (result, uint16([0 0 0 0; 1 2 2 0; 5 6 5 0; 9 10 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = uint16(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "cubic");
%! assert (result, uint16(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## int16
%!
%!test
%! ## Test zero translation (identity)
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "cubic");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "cubic");
%! assert (result, int16([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "cubic");
%! assert (result, int16([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "cubic");
%! assert (result, int16([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "cubic");
%! assert (result, int16([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "cubic");
%! assert (result, int16([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "cubic");
%! assert (result, int16([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "cubic");
%! assert (result, int16([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "cubic");
%! assert (result, int16([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "cubic");
%! assert (result, int16([0 0 0 0; 0 0 1 1; 1 3 4 5; 5 7 8 10]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int16([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "cubic");
%! assert (result, int16([0 0 0 0; 1 2 2 0; 5 6 5 0; 9 10 8 -1]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = int16(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "cubic");
%! assert (result, int16(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## uint32
%!
%!test
%! ## Test zero translation (identity)
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "cubic");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "cubic");
%! assert (result, uint32([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "cubic");
%! assert (result, uint32([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "cubic");
%! assert (result, uint32([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "cubic");
%! assert (result, uint32([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "cubic");
%! assert (result, uint32([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "cubic");
%! assert (result, uint32([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "cubic");
%! assert (result, uint32([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "cubic");
%! assert (result, uint32([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "cubic");
%! assert (result, uint32([0 0 0 0; 0 0 1 1; 1 3 4 5; 5 7 8 10]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = uint32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "cubic");
%! assert (result, uint32([0 0 0 0; 1 2 2 0; 5 6 5 0; 9 10 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = uint32(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "cubic");
%! assert (result, uint32(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## int32
%!
%!test
%! ## Test zero translation (identity)
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "cubic");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "cubic");
%! assert (result, int32([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "cubic");
%! assert (result, int32([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "cubic");
%! assert (result, int32([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "cubic");
%! assert (result, int32([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "cubic");
%! assert (result, int32([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "cubic");
%! assert (result, int32([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "cubic");
%! assert (result, int32([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "cubic");
%! assert (result, int32([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "cubic");
%! assert (result, int32([0 0 0 0; 0 0 1 1; 1 3 4 5; 5 7 8 10]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = int32([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "cubic");
%! assert (result, int32([0 0 0 0; 1 2 2 0; 5 6 5 0; 9 10 8 -1]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = int32(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "cubic");
%! assert (result, int32(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## single
%!
%!test
%! ## Test zero translation (identity)
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "cubic");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "cubic");
%! assert (result, single([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "cubic");
%! assert (result, single([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "cubic");
%! assert (result, single([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "cubic");
%! assert (result, single([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "cubic");
%! assert (result, single([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "cubic");
%! assert (result, single([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "cubic");
%! assert (result, single([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "cubic");
%! assert (result, single([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "cubic");
%! expected = [-0.0211   -0.0535   -0.0851   -0.1281; ...
%!              0.0790    0.3086    0.5706    0.9142; ...
%!              1.3899    2.7595    3.8045    5.3391; ...
%!              4.5269    7.0638    7.9000    9.6497];
%! assert (result, single(expected), 6e-5)
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = single([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "cubic");
%! expected = [-0.1656   -0.2489   -0.2190    0.0212; ...
%!              1.1472    1.8604    1.6842   -0.1623; ...
%!              4.6184    5.9010    4.8258   -0.4704; ...
%!              8.7000   10.0591    7.7903   -0.7644];
%! assert (result, single(expected), 6e-5)
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = single(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "cubic");
%! assert (result, single(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%! ## double
%!
%!test
%! ## Test zero translation (identity)
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 0], "cubic");
%! assert (result, img)
%! assert (size(result), size(img));
%!
%!test
%! ## Test X-only positive integer translation
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [2, 0], "cubic");
%! assert (result, double([0 0 1 2; 0 0 5 6; 0 0 9 10; 0 0 13 14]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test X-only negative integer translation
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 0], "cubic");
%! assert (result, double([2 3 4 0; 6 7 8 0; 10 11 12 0; 14 15 16 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only positive integer translation
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, 2], "cubic");
%! assert (result, double([0 0 0 0; 0 0 0 0; 1 2 3 4; 5 6 7 8]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test Y-only negative integer translation
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0, -2], "cubic");
%! assert (result, double([9 10 11 12; 13 14 15 16; 0 0 0 0; 0 0 0 0]))
%! assert (isequal(size(result), size(img)));
%!
%!test
%! ## Test basic translation - positive offset
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, 2], "cubic");
%! assert (result, double([0 0 0 0; 0 0 0 0; 0 1 2 3; 0 5 6 7]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - negative offset
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-2, -1], "cubic");
%! assert (result, double([7 8 0 0; 11 12 0 0; 15 16 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [1, -2], "cubic");
%! assert (result, double([0 9 10 11; 0 13 14 15; 0 0 0 0; 0 0 0 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test basic translation - general offset
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1, 2], "cubic");
%! assert (result, double([0 0 0 0; 0 0 0 0; 2 3 4 0; 6 7 8 0]))
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "cubic");
%! expected = [-0.0211   -0.0535   -0.0851   -0.1281; ...
%!              0.0790    0.3086    0.5706    0.9142; ...
%!              1.3899    2.7595    3.8045    5.3391; ...
%!              4.5269    7.0638    7.9000    9.6497];
%! assert (result, double(expected), 6e-5)
%! assert (size(result), size(img));
%!
%!test
%! ## Test fractional translation (subpixel)
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [-1.3, 1.4], "cubic");
%! expected = [-0.1656   -0.2489   -0.2190    0.0212; ...
%!              1.1472    1.8604    1.6842   -0.1623; ...
%!              4.6184    5.9010    4.8258   -0.4704; ...
%!              8.7000   10.0591    7.7903   -0.7644];
%! assert (result, double(expected), 6e-5)
%! assert (size(result), size(img));
%!
%!test
%! ## Test large translation
%! img = double(ones(10, 10) * 50);
%! result = imtranslate(img, [20, 20], "cubic");
%! assert (result, double(zeros(10, 10)))
%! assert (size(result), size(img));
%!
%!
%! ##############################################################################
%! ## RGB AND MULTICHANNEL IMAGE TESTS
%! ##############################################################################
%!
%!test
%! ## Test RGB image (3 channels)
%! img = uint8(zeros(3, 3, 3));
%! img(:,:,1) = [1 2 3; 4 5 6; 7 8 9];
%! img(:,:,2) = [10 11 12; 13 14 15; 16 17 18];
%! img(:,:,3) = [19 20 21; 22 23 24; 25 26 27];
%! result = imtranslate(img, [1.6, -0.8]);
%! expected = uint8(zeros(3, 3, 3));
%! expected(:, :, 1) = [0 1 4; 0 3 7; 0 1 1];
%! expected(:, :, 2) = [0 5 13; 0 6 16; 0 1 3];
%! expected(:, :, 3) = [0 9 22; 0 10 25; 0 2 5];
%! assert (result, expected)
%! assert (size(result, 3), 3);
%! assert (class(result), "uint8");
%!
%!test
%! ## Test RGB image (3 channels)
%! img = double(zeros(3, 3, 3));
%! img(:,:,1) = [1 2 3; 4 5 6; 7 8 9];
%! img(:,:,2) = [10 11 12; 13 14 15; 16 17 18];
%! img(:,:,3) = [19 20 21; 22 23 24; 25 26 27];
%! result = imtranslate(img, [1.6, -0.8]);
%! expected = double(zeros(3, 3, 3));
%! expected(:, :, 1) = [0 1.36 3.8; 0 2.56 6.8; 0 0.56 1.48];
%! expected(:, :, 2) = [0 4.96 12.8; 0 6.16 15.8; 0 1.28 3.28];
%! expected(:, :, 3) = [0 8.56 21.8; 0 9.76 24.8; 0 2 5.08];
%! assert (result, expected, 1e-14)
%! assert (size(result, 3), 3);
%! assert (class(result), "double");
%!
%!test
%! ## Test RGB image (4 channels)
%! img = double(zeros(3, 3, 4));
%! img(:,:,1) = [1 2 3; 4 5 6; 7 8 9];
%! img(:,:,2) = [10 11 12; 13 14 15; 16 17 18];
%! img(:,:,3) = [19 20 21; 22 23 24; 25 26 27];
%! img(:,:,4) = [1 2 3; 4 5 6; 7 8 9];
%! result = imtranslate(img, [1.6, -0.8]);
%! expected = double(zeros(3, 3, 4));
%! expected(:, :, 1) = [0 1.36 3.8; 0 2.56 6.8; 0 0.56 1.48];
%! expected(:, :, 2) = [0 4.96 12.8; 0 6.16 15.8; 0 1.28 3.28];
%! expected(:, :, 3) = [0 8.56 21.8; 0 9.76 24.8; 0 2 5.08];
%! expected(:, :, 4) = [0 1.36 3.8; 0 2.56 6.8; 0 0.56 1.48];
%! assert (result, expected, 1e-14)
%! assert (size(result, 3), 4);
%! assert (class(result), "double");
%!
%!
%! ##############################################################################
%! ## NAME-VALUE PARAMETER TESTS
%! ##############################################################################
%!
%! ## Test OutputView
%!test
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "OutputView", "same");
%! assert (result, uint8([0 0 0 0; 0 1 1 1; 2 3 4 5; 4 7 8 9]))
%! assert (size(result), size(img));
%!
%!test
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "OutputView", "full");
%! assert (result, uint8([0  0  0  0  0; ...
%!                           0  1  1  1  0; ...
%!                           2  3  4  5  2; ...
%!                           4  7  8  9  3; ...
%!                           7 11 12 13  4; ...
%!                           6 10 10 11  3]))
%! assert (size(result), [6, 5])
%!
%!test
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "OutputView", "same");
%! assert (result, double([0 0 0 0; 0.21 0.51 0.81 1.11; 1.54 2.9 3.9 4.9; 4.34 6.9 7.9 8.9]), 4e-15)
%! assert (size(result), size(img));
%!
%!test
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "OutputView", "full");
%! assert (result, double([0  0  0  0  0; ...
%!                           0.21   0.51  0.81   1.11  0.36; ...
%!                           1.54   2.90  3.90   4.90  1.56; ...
%!                           4.34   6.90  7.90   8.90  2.76; ...
%!                           7.14  10.90  11.9  12.90  3.96; ...
%!                           6.37   9.59  10.29 10.99  3.36]), 5.e-14)
%! assert (size(result), [6, 5])
%!
%! ## Test OutputView with RGB image (3 channels)
%!test
%! img = uint8(zeros(3, 3, 3));
%! img(:,:,1) = [1 2 3; 4 5 6; 7 8 9];
%! img(:,:,2) = [10 11 12; 13 14 15; 16 17 18];
%! img(:,:,3) = [19 20 21; 22 23 24; 25 26 27];
%! result = imtranslate(img, [1.6, -0.8], "OutputView", "same");
%! expected = uint8(zeros(3, 3, 3));
%! expected(:, :, 1) = [0 1 4; 0 3 7; 0 1 1];
%! expected(:, :, 2) = [0 5 13; 0 6 16; 0 1 3];
%! expected(:, :, 3) = [0 9 22; 0 10 25; 0 2 5];
%! assert (result, expected)
%! assert (size(result, 3), 3);
%!
%!test
%! img = uint8(zeros(3, 3, 3));
%! img(:,:,1) = [1 2 3; 4 5 6; 7 8 9];
%! img(:,:,2) = [10 11 12; 13 14 15; 16 17 18];
%! img(:,:,3) = [19 20 21; 22 23 24; 25 26 27];
%! result = imtranslate(img, [1.6, -0.8], "OutputView", "full");
%! expected = uint8(zeros(4, 5, 3));
%! expected(:, :, 1) = [0 0 1 2 1; 0 1 4 5 3; 0 3 7 8 5; 0 1 1 2 1];
%! expected(:, :, 2) = [0 3 8 9 6; 0 5 13 14 9; 0 6 16 17 10; 0 1 3 3 2];
%! expected(:, :, 3) = [0 6 16 16 10;0 9 22 23 14; 0 10 25 26 16; 0 2 5 5 3];
%! assert (result, expected)
%! assert (size(result, 3), 3);
%!
%!
%! img = uint8(zeros(3, 3, 3));
%! img(:,:,1) = [1 2 3; 4 5 6; 7 8 9];
%! img(:,:,2) = [10 11 12; 13 14 15; 16 17 18];
%! img(:,:,3) = [19 20 21; 22 23 24; 25 26 27];
%! result = imtranslate(img, [1.6, -0.8], "OutputView", "same");
%! expected = uint8(zeros(3, 3, 3));
%! expected(:, :, 1) = [0 1 4; 0 3 7; 0 1 1];
%! expected(:, :, 2) = [0 5 13; 0 6 16; 0 1 3];
%! expected(:, :, 3) = [0 9 22; 0 10 25; 0 2 5];
%! assert (result, expected)
%! assert (size(result, 3), 3);
%! assert (class(result), "uint8");
%!
%!test
%! img = uint8(zeros(3, 3, 3));
%! img(:,:,1) = [1 2 3; 4 5 6; 7 8 9];
%! img(:,:,2) = [10 11 12; 13 14 15; 16 17 18];
%! img(:,:,3) = [19 20 21; 22 23 24; 25 26 27];
%! result = imtranslate(img, [1.6, -0.8], "OutputView", "full");
%! expected = uint8(zeros(4, 5, 3));
%! expected(:, :, 1) = [0 0 1 2 1; 0 1 4 5 3; 0 3 7 8 5; 0 1 1 2 1];
%! expected(:, :, 2) = [0 3 8 9 6; 0 5 13 14 9; 0 6 16 17 10; 0 1 3 3 2];
%! expected(:, :, 3) = [0 6 16 16 10;0 9 22 23 14; 0 10 25 26 16; 0 2 5 5 3];
%! assert (result, expected)
%! assert (size(result, 3), 3);
%! assert (class(result), "uint8");
%!
%!test
%! img = double(zeros(3, 3, 3));
%! img(:,:,1) = [1 2 3; 4 5 6; 7 8 9];
%! img(:,:,2) = [10 11 12; 13 14 15; 16 17 18];
%! img(:,:,3) = [19 20 21; 22 23 24; 25 26 27];
%! result = imtranslate(img, [1.6, -0.8], "OutputView", "same");
%! expected = double(zeros(3, 3, 3));
%! expected(:, :, 1) = [0.00 1.36 3.8;  0.00 2.56 6.8; 0.00 0.56 1.48];
%! expected(:, :, 2) = [0.00 4.96 12.8; 0.00 6.16 15.8; 0.00 1.28 3.28];
%! expected(:, :, 3) = [0.00 8.56 21.8; 0.00 9.76 24.8; 0.00 2.00 5.08];
%! assert (result, expected, 1e-14)
%! assert (size(result, 3), 3);
%! assert (class(result), "double");
%!
%!test
%! img = double(zeros(3, 3, 3));
%! img(:,:,1) = [1 2 3; 4 5 6; 7 8 9];
%! img(:,:,2) = [10 11 12; 13 14 15; 16 17 18];
%! img(:,:,3) = [19 20 21; 22 23 24; 25 26 27];
%! result = imtranslate(img, [1.6, -0.8], "OutputView", "full");
%! expected = double(zeros(4, 5, 3));
%! expected(:, :, 1) = [0.00 0.32   1.12  1.92 1.44; ...
%!                      0.00 1.36   3.80  4.80 3.24; ...
%!                      0.00 2.56   6.80  7.80 5.04; ...
%!                      0.00 0.56   1.48  1.68 1.08];
%! expected(:, :, 2) = [0.00 3.20   8.32  9.12  5.76; ...
%!                      0.00 4.96  12.80 13.80  8.64; ...
%!                      0.00 6.16  15.8  16.80 10.44; ...
%!                      0.00 1.28  3.28   3.48  2.16];
%! expected(:, :, 3) = [0.00  6.08  15.52  16.32  10.08; ...
%!                      0.00  8.56  21.80  22.80  14.04; ...
%!                      0.00  9.76  24.80  25.80  15.84; ...
%!                      0.00  2.00   5.08   5.28   3.24];
%! assert (result, expected, 5e-14)
%! assert (size(result, 3), 3);
%! assert (class(result), "double");
%!
%! ## Test fillValues
%!test
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "Fillvalues", 0);
%! assert (result, uint8([0 0 0 0; 0 1 1 1; 2 3 4 5; 4 7 8 9]))
%! assert (size(result), size(img));
%!
%!test
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "Fillvalues", 0);
%! assert (result, double([0 0 0 0; 0.21 0.51 0.81 1.11; 1.54 2.9 3.9 4.9; 4.34 6.9 7.9 8.9]), 4e-15)
%! assert (size(result), size(img));
%!
%!test
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "Fillvalues", 255);
%! assert (result, uint8([255 255 255 255; 202 179 179 180; 78 3 4 5; 81 7 8 9]))
%! assert (size(result), size(img));
%!
%!test
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "Fillvalues", 255);
%! assert (result, double([255.00  255.00 255.00 255.00; ...
%!                            201.66  179.01 179.31 179.61; ...
%!                            78.04     2.90   3.90   4.90; ...
%!                            80.84     6.90   7.90   8.90]), 5e-14)
%! assert (size(result), size(img));
%!
%!
%! ## Test OutputView & Fillvalues
%!test
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "OutputView", "same", "Fillvalues", 0);
%! assert (result, uint8([0 0 0 0; 0 1 1 1; 2 3 4 5; 4 7 8 9]))
%! assert (size(result), size(img));
%!
%!test
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "OutputView", "full", "Fillvalues", 0);
%! assert (result, uint8([0  0  0  0  0; ...
%!                           0  1  1  1  0; ...
%!                           2  3  4  5  2; ...
%!                           4  7  8  9  3; ...
%!                           7 11 12 13  4; ...
%!                           6 10 10 11  3]))
%! assert (size(result), [6, 5])
%!
%!test
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "OutputView", "same", "Fillvalues", 0);
%! assert (result, double([0.00 0.00 0.00 0.00; ...
%!                            0.21 0.51 0.81 1.11; ...
%!                            1.54 2.90 3.90 4.90; ...
%!                            4.34 6.90 7.90 8.90]), 4e-15)
%! assert (size(result), size(img));
%!
%!test
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "OutputView", "full", "Fillvalues", 0);
%! assert (result, double([0.00   0.00  0.00   0.00  0.00; ...
%!                            0.21   0.51  0.81   1.11  0.36; ...
%!                            1.54   2.90  3.90   4.90  1.56; ...
%!                            4.34   6.90  7.90   8.90  2.76; ...
%!                            7.14  10.90  11.9  12.90  3.96; ...
%!                            6.37   9.59  10.29 10.99  3.36]), 5.e-14)
%! assert (size(result), [6, 5])
%!
%!test
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "OutputView", "same", "Fillvalues", 255);
%! assert (result, uint8([255 255 255 255; 202 179 179 180; 78 3 4 5; 81 7 8 9]))
%! assert (size(result), size(img));
%!
%!test
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "OutputView", "full", "Fillvalues", 255);
%! assert (result, uint8([255  255  255  255  255; ...
%!                           202  179  179  180  232; ...
%!                           78     3    4    5  180; ...
%!                           81     7    8    9  181; ...
%!                           84    11   12   13  182; ...
%!                           136   86   87   87  205]))
%! assert (size(result), [6, 5])
%!
%!test
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "OutputView", "same", "Fillvalues", 255);
%! assert (result, double([255.00  255.00  255.00 255.00; ...
%!                            201.66  179.01  179.31 179.61; ...
%!                             78.04   2.90    3.90   4.90; ...
%!                             80.84   6.90    7.90   8.90]), 5e-14)
%! assert (size(result), size(img));
%!
%!test
%! img = double([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! result = imtranslate(img, [0.3, 1.7], "OutputView", "full", "Fillvalues", 255);
%! assert (result, double([255.00   255.00  255.00   255.00  255.00; ...
%!                            201.66   179.01  179.31   179.61  232.41; ...
%!                             78.04    2.90     3.90     4.90  180.06; ...
%!                             80.84    6.90     7.90     8.90  181.26; ...
%!                             83.64   10.90    11.90    12.90  182.46; ...
%!                            136.42   86.09    86.79    87.49  204.81]), 6.e-14)
%! assert (size(result), [6, 5])
%!
%!test
%! img = double(zeros(3, 3, 3));
%! img(:,:,1) = [1 2 3; 4 5 6; 7 8 9];
%! img(:,:,2) = [10 11 12; 13 14 15; 16 17 18];
%! img(:,:,3) = [19 20 21; 22 23 24; 25 26 27];
%! result = imtranslate(img, [1.6, -0.8], "OutputView", "same", ...
%!                       "Fillvalues", [255, 128, 0]);
%! expected = double(zeros(3, 3, 3));
%! expected(:, :, 1) = [255.00 154.36 3.8;  255.00 155.56 6.8; 255.00 235.16 205.48];
%! expected(:, :, 2) = [128.00 81.76 12.8; 128.00 82.96 15.8; 128.00 119.04 105.68];
%! expected(:, :, 3) = [  0.00 8.56 21.8; 0.00 9.76 24.8; 0.00 2.00 5.08];
%! assert (result, expected, 5e-14)
%! assert (size(result, 3), 3);
%! assert (class(result), "double");
%!
%!test
%! img = double(zeros(3, 3, 3));
%! img(:,:,1) = [1 2 3; 4 5 6; 7 8 9];
%! img(:,:,2) = [10 11 12; 13 14 15; 16 17 18];
%! img(:,:,3) = [19 20 21; 22 23 24; 25 26 27];
%! result = imtranslate(img, [1.6, -0.8], "OutputView", "full", ...
%!                       "Fillvalues", [255, 128, 0]);
%! expected = double(zeros(4, 5, 3));
%! expected(:, :, 1) = [255.00 173.72    52.12   52.92  134.04; ...
%!                      255.00 154.36     3.80    4.80  105.24; ...
%!                      255.00 155.56     6.80    7.80  107.04; ...
%!                      255.00 235.16   205.48  205.68  225.48];
%! expected(:, :, 2) = [128.00  90.24   33.92  34.72   72.32; ...
%!                      128.00  81.76   12.80  13.80   59.84; ...
%!                      128.00  82.96   15.80  16.80   61.64; ...
%!                      128.00 119.04  105.68  105.88  114.80];
%! expected(:, :, 3) = [0.00  6.08  15.52  16.32  10.08; ...
%!                      0.00  8.56  21.80  22.80  14.04; ...
%!                      0.00  9.76  24.80  25.80  15.84; ...
%!                      0.00  2.00   5.08   5.28   3.24];
%! assert (result, expected, 5e-13)
%! assert (size(result, 3), 3);
%! assert (class(result), "double");
%!
%!
%! ##############################################################################
%! ## Checking reference image input & output
%! ##############################################################################
%!
%!test
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! [result, RB] = imtranslate(img, [0.3, 1.7], "OutputView", "same");
%! assert (result, uint8([0 0 0 0; 0 1 1 1; 2 3 4 5; 4 7 8 9]))
%! assert (size(result), size(img));
%! RB_exp = imref2d(size(result));
%! assert (isequal(RB, RB_exp));
%!
%!test
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! [result, RB] = imtranslate(img, [0.3, 1.7], "OutputView", "full");
%! assert (result, uint8([0  0  0  0  0; ...
%!                           0  1  1  1  0; ...
%!                           2  3  4  5  2; ...
%!                           4  7  8  9  3; ...
%!                           7 11 12 13  4; ...
%!                           6 10 10 11  3]))
%! assert (size(result), [6, 5])
%! RB_exp = imref2d(size(result));
%! assert (isequal(RB, RB_exp));
%!
%!
%!test
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! RA = imref2d(size(img));
%! [result, RB] = imtranslate(img, RA, [0.3, 1.7], "OutputView", "same");
%! assert (result, uint8([0 0 0 0; 0 1 1 1; 2 3 4 5; 4 7 8 9]))
%! assert (size(result), size(img));
%! RB_exp = imref2d(size(result));
%! assert (isequal(RB, RB_exp));
%!
%!test
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! RA = imref2d(size(img));
%! [result, RB] = imtranslate(img, RA, [0.3, 1.7], "OutputView", "full");
%! assert (result, uint8([0  0  0  0  0; ...
%!                           0  1  1  1  0; ...
%!                           2  3  4  5  2; ...
%!                           4  7  8  9  3; ...
%!                           7 11 12 13  4; ...
%!                           6 10 10 11  3]))
%! assert (size(result), [6, 5])
%! RB_exp = imref2d(size(result));
%! assert (isequal(RB, RB_exp));
%!
%!test
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! RA = imref2d([4, 4], 2, 1);
%! [result, RB] = imtranslate(img, RA, [0.3, 1.7], "OutputView", "same");
%! assert (result, uint8([0 0 0 0; 0 1 1 1; 2 3 4 5; 5 7 8 9]))
%! assert (size(result), size(img));
%! RB_exp = RA;
%! assert (isequal(RB, RB_exp));
%!
%!test
%! img = uint8([1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]);
%! RA = imref2d([4, 4], 2, 1);
%! [result, RB] = imtranslate(img, RA, [0.3, 1.7], "OutputView", "full");
%! assert (result, uint8([0  0  0  0  0; ...
%!                           0  1  1  1  0; ...
%!                           2  3  4  5  1; ...
%!                           5  7  8  9  1; ...
%!                           9 11 12 13  2; ...
%!                           8 10 10 11  2]))
%! assert (size(result), [6, 5])
%! RB_exp = imref2d(size(result), 2, 1);
%! assert (isequal(RB, RB_exp));
%!
%! ## Test reference image input & output using RGB image (3 channels)
%!test
%! img = uint8(zeros(3, 3, 3));
%! img(:,:,1) = [1 2 3; 4 5 6; 7 8 9];
%! img(:,:,2) = [10 11 12; 13 14 15; 16 17 18];
%! img(:,:,3) = [19 20 21; 22 23 24; 25 26 27];
%! RA = imref2d(size(img, 1:2));
%! [result, RB] = imtranslate(img, RA, [1.6, -0.8], "OutputView", "same");
%! expected = uint8(zeros(3, 3, 3));
%! expected(:, :, 1) = [0 1 4; 0 3 7; 0 1 1];
%! expected(:, :, 2) = [0 5 13; 0 6 16; 0 1 3];
%! expected(:, :, 3) = [0 9 22; 0 10 25; 0 2 5];
%! assert (result, expected)
%! RB_exp = imref2d(size(result));
%! assert (isequal(RB, RB_exp));
%!
%!test
%! img = uint8(zeros(3, 3, 3));
%! img(:,:,1) = [1 2 3; 4 5 6; 7 8 9];
%! img(:,:,2) = [10 11 12; 13 14 15; 16 17 18];
%! img(:,:,3) = [19 20 21; 22 23 24; 25 26 27];
%! RA = imref2d(size(img, 1:2), 2, 1);
%! [result, RB] = imtranslate(img, RA, [1.6, -0.8], "OutputView", "same");
%! expected = uint8(zeros(3, 3, 3));
%! expected(:, :, 1) = [1 4 5; 1 7 8; 0 1 2];
%! expected(:, :, 2) = [2 13 14; 3 16 17; 1 3 3];
%! expected(:, :, 3) = [4 22 23; 5 25 26; 1 5 5];
%! assert (result, expected)
%! RB_exp = imref2d(size(result), 2, 1);
%! assert (isequal(RB, RB_exp));
%!
%!test
%! img = uint8(zeros(3, 3, 3));
%! img(:,:,1) = [1 2 3; 4 5 6; 7 8 9];
%! img(:,:,2) = [10 11 12; 13 14 15; 16 17 18];
%! img(:,:,3) = [19 20 21; 22 23 24; 25 26 27];
%! RA = imref2d(size(img, 1:2));
%! [result, RB] = imtranslate(img, RA, [1.6, -0.8], "OutputView", "full");
%! expected = uint8(zeros(4, 5, 3));
%! expected(:, :, 1) = [0 0 1 2 1; 0 1 4 5 3; 0 3 7 8 5; 0 1 1 2 1];
%! expected(:, :, 2) = [0 3 8 9 6; 0 5 13 14 9; 0 6 16 17 10; 0 1 3 3 2];
%! expected(:, :, 3) = [0 6 16 16 10;0 9 22 23 14; 0 10 25 26 16; 0 2 5 5 3];
%! assert (result, expected)
%! RB_exp = imref2d(size(result), [0.5, 5.5], [-0.5, 3.5]);
%! assert (isequal(RB, RB_exp));
%!
%!test
%! img = uint8(zeros(3, 3, 3));
%! img(:,:,1) = [1 2 3; 4 5 6; 7 8 9];
%! img(:,:,2) = [10 11 12; 13 14 15; 16 17 18];
%! img(:,:,3) = [19 20 21; 22 23 24; 25 26 27];
%! RA = imref2d(size(img, 1:2), 2, 1);
%! [result, RB] = imtranslate(img, RA, [1.6, -0.8], "OutputView", "full");
%! expected = uint8(zeros(4, 4, 3));
%! expected(:, :, 1) = [0 1 2 2; 1 4 5 4; 1 7 8 7; 0 1 2 1];
%! expected(:, :, 2) = [2 8 9 8; 2 13 14 12; 3 16 17 14; 1 3 3 3];
%! expected(:, :, 3) = [3 15 16 13; 4 22 23 19; 5 25 26 21; 1 5 5 4];
%! assert (result, expected)
%! RB_exp = imref2d(size(result), [1, 9], [-0.5, 3.5]);
%! assert (isequal(RB, RB_exp));
%!
##############################################################################
## ERROR HANDLING TESTS
##############################################################################

%!error <Invalid call to imtranslate> imtranslate()
%!error <Invalid call to imtranslate> imtranslate(ones(5))
%!error <imtranslate: The input img must be a valid image> imtranslate("aaaa", [1, 1])
%!error <imtranslate: The input img must be a finite value image> imtranslate(1.0./zeros(3), [1, 1])
%!error <imtranslate: Translation must be a real numeric> imtranslate(ones(5), [1])
%!error <imtranslate: Translation must be a real numeric> imtranslate(ones(5), [1, 2, 3])
%!error <imtranslate: ref_input should be the 2nd input> imtranslate(ones(5), [1, 2], imref2d([5, 5]))
%!error <imtranslate: ref_input should be the 2nd input> imtranslate(ones(5), [1, 2], imref2d([5, 5]))
%!error <imtranslate: Not enough inputs> imtranslate(ones(5), imref2d([5, 5]))
%!error imtranslate(ones(5), [1, 2], "not valid method")
%!error imtranslate(ones(5), [1, 2], "fillvalues")
%!error <imtranslate: failed validation of > imtranslate(ones(5), [1, 2], "fillvalues", "aa")
%!error <imtranslate: failed validation of> imtranslate(ones(5), [1, 2], "fillvalues", "NaN")
%!error <imtranslate: For a 2D image, FillValues should be a scalar.> imtranslate(ones(5), [1, 2], "fillvalues", [0, 0])
%!error <imtranslate: For a multi-channel image> imtranslate(ones(5, 5, 3), [1, 2], "fillvalues", [0, 0])
%!error <imtranslate: failed validation of> imtranslate(ones(5), [1, 2], "OutputView", "aaa")
%!error <imtranslate: image size of input_ref must match img size> imtranslate(ones(5), imref2d([4, 5]), [0, 0])
%!error <imtranslate: function called with too many outputs> [a, b, c] = imtranslate(ones(5), [1, 1])

