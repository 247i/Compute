########################################################################
##
## Copyright (C) 2025 The Octave Project Developers
##
## See the file COPYRIGHT.md in the top-level directory of this
## distribution or https://octave.org/copyright/.
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
##
########################################################################

## -*- texinfo -*-
## @deftypefn  {} {@var{rgb} =} insertText (@var{img}, @var{pos}, @var{txt})
## @deftypefnx {} {@var{rgb} =} insertText (@var{img}, @var{pos}, @var{numerical_value})
## @deftypefnx {} {@var{rgb} =} insertText (@dots{}, @var{param1}, @var{value1}, @dots{})
## Insert text in image.
##
## This function inserts the specified @var{text} into the given @var{image}
## at the specified @var{position}.
## The function returns a modified image with text annotation.
##
## @strong{Inputs}
##
## @table @var
## @item image
## An MxN array representing a grayscale image or an MxNx3 array representing
## an RGB image where text will be inserted.
##
## @item position
## An Nx2 array specifying the (x, y) coordinates for each text annotation.
## Each row corresponds to a position for a text string in the image.
##
## @item text
## A cell array of strings containing the text to be inserted at each specified position.
## The number of strings must match the number of positions.
##
## @item numerical_value
## Numerical values to be inserted at each specified position.
## The number of strings must match the number of positions.
##
## @item varargin
## Additional name-value pair arguments to control text properties
## such as 'Font', 'FontSize', 'FontColor' / 'TextColor', 'TextBoxColor',
## 'BoxOpacity', 'AnchorPoint'.
##
## @end table
##
## @strong{Name-Value Pair Arguments}
##
## @table @var
## @item 'Font'
## A string specifying the font name. Default is "LucidaSansRegular"
##
## @item 'FontSize'
## A positive number specifying the font size of the text. Default is 12.
##
## @item 'FontColor' / 'TextColor'
## A 1x3 RGB vector specifying the color of the text. Default is [0, 0, 0] (black).
## For grayscale images, the color will be converted to a corresponding grayscale intensity.
##
## @item 'TextBoxColor'
## A 1x3 RGB vector specifying the color of the text box. Default is [1, 1, 1] (white).
## For grayscale images, the color will be converted to a corresponding grayscale intensity.
##
## @item 'BoxOpacity'
## A scalar between 0 and 1 specifying the opacity of the text box. Default is 0.6.
##
## @item 'AnchorPoint'
## A string specifying which part of the text box is anchored to the position.
## Options include 'LeftTop', 'LeftCenter', 'LeftBottom', 'CenterTop', 'Center',
## 'CenterBottom', 'RightTop', 'RightCenter', 'RightBottom'. Default is 'LeftTop'.
##
## @end table
##
## @strong{Outputs}
##
## @table @var
## @item outputImage
## An MxNx3 array for an RGB image representing the modified image with text annotations.
##
## @end table
##
## @strong{Example}
##
## @verbatim
## image = imread('example.jpg');
## position = [50, 100; 150, 200];
## text = {'Hello', 'World'};
## outputImage = insertText(image, position, text, 'FontSize', 20, 'TextColor', [1, 0, 0], 'AnchorPoint', 'Center');
## imshow(outputImage);
## @end verbatim
##
## @seealso{text, imshow, imread}
##
## @end deftypefn

function rgb = insertText (img, pos, txt, varargin)

  if (nargin < 3 || mod (numel (varargin), 2) || nargout > 1)
    print_usage ();
  endif

  if (! isnumeric (img) || ! isreal (img) || ...
      ! (ismatrix (img) || (ndims (img) ==3 && size (img, 3) == 3)))
    error ("insertText: IMG must be an RGB or grayscale image")
  endif

  if size(img, 1) == 1 || size(img, 2) == 1
    error ("insertText: IMG should be non-degenerate (size = 1)")
  endif

  if (! ischar (txt) && ! iscellstr (txt) && ! isnumeric (txt))
    error ("insertText: TXT must be a character array or a cell array of strings");
  endif
  if (ischar (txt))
    txt = cellstr (txt);
  endif
  if (isnumeric (txt))
    txt = arrayfun (@(x) sprintf ("%0.5g", x), txt, "UniformOutput", false);
  endif

  if (! isnumeric (pos) || !ismatrix (pos) || size (pos, 2) != 2)
    error ("insertText: POS must be an array of coordinates");
  endif
  if (numel (txt) != size (pos, 1))
    if (numel (txt) > 1)
      error ("insertText: POS must be an array of coordinates");
    else
      txt = repmat (txt, 1, size (pos, 1));
    endif
  endif

  options = containers.Map (...
    {"font", "fontsize", "fontcolor", "textcolor", "textboxcolor", "boxopacity", "anchorpoint"}, ...
    {"LucidaSansRegular", 12, "black", "black", "yellow", 0.6, "lefttop"});

  anchor_point = containers.Map(...
    {"lefttop", "leftcenter", "leftbottom", "centertop", "center", ...
    "centerbottom", "righttop", "rightcenter", "rightbottom"}, ...
    {[0 0], [0 0.5], [0 1] ,[0.5 0], [0.5 0.5], [0.5 1], [1 0], [1 0.5], [1 1]});

  for i=1:2:numel (varargin)
    [param, value] = deal (varargin{i:i+1});
    if (! ischar (param))
      error ("insertText: parameter must be a string");
    endif
    param = tolower (param);
    switch (param)
      case "font"
        if (! ischar (value) || ! isrow (value))
          error ("insertText: Font must be a string");
        endif
      case "fontsize"
        if (! isnumeric (value) || ! isscalar (value) || value < 1)
          error ("insertText: FontSize must be a positive scalar value");
        endif
      case {"fontcolor", "textcolor"}
        if (! ischar (value) && ! iscellstr (value) && ...
            ! (isnumeric (value) && ismatrix (value) && size (value, 2) == 3))
          error ("insertText: %s must be RGB values or color names", param);
        endif
        options("fontcolor") = value;
      case "textboxcolor"
        if (! ischar (value) && ! iscellstr (value) && ...
            ! (isnumeric (value) && ismatrix (value) && size (value, 2) == 3))
          error ("insertText: %s must be RGB values or color names", param);
        endif
      case "boxopacity"
        if (! isnumeric (value) || ! isscalar (value) || value < 0 || value > 1)
          error ("insertText: BoxOpacity must be a scalar between 0 and 1");
        endif
      case "anchorpoint"
        if (!ischar (value) || ! ismember (tolower (value), keys (anchor_point)))
          error ("insertText: AnchorPoint must be a string");
        endif
        value = tolower (value);
      otherwise
        error ("insertText: unknown optional argument %s", param);
    endswitch
    options(param) = value;
  endfor

  ## Output RGB image
  if (ismatrix (img))
    rgb = repmat (img, [1 1 3]);
  else
    rgb = img;
  endif

  if (isinteger (img))
    rgb = double (rgb) / 255;
  endif

  ## TextColor
  text_color = options("fontcolor");
  if (ischar (text_color) || iscellstr(text_color))
    text_color = str2rgb (text_color);
  endif
  if (size (text_color,1) != size (pos, 1))
    if (size (text_color, 1) > 1)
      error ("insertText: TextColor must be RGB values or color names");
    else
      text_color = repmat (text_color, size (pos, 1), 1);
    endif
  endif

  ## BoxColor
  if (options("boxopacity") > 0)
    box_color = options("textboxcolor");
    if (ischar (box_color) || iscellstr(box_color))
      box_color = str2rgb (box_color);
    endif

    if (size (box_color, 1) != size (pos, 1))
      if (size (box_color, 1) > 1)
        error ("insertText: BoxColor must be a RGB values or color names");
      else
        box_color = repmat (box_color, size (pos, 1), 1);
      endif
    endif
  endif

  for i=1:numel (txt)

    ## Get text
    RGBA = __text_to_pixels__ (txt{i}, options("font"), options("fontsize"));
    alpha = double (flipud (permute (RGBA(4,:,:), [3 2 1]))) / 255;

    ## Pad for box
    if (options("boxopacity") > 0)
      pad_size = round (0.5 * size (alpha, 1));
      alpha = padarray (alpha, [pad_size pad_size], 0);
    endif

    ## Get indices
    ap = anchor_point(options("anchorpoint"));
    bbox = [0, 0, size(alpha, 2), size(alpha, 1)];
    bbox = [round(pos(i,:)-ap.*bbox(3:4)), bbox(3:4)];
    idx_row = bbox(2):(bbox(2)+bbox(4)-1);
    idx_col = bbox(1):(bbox(1)+bbox(3)-1);

    ## Crop
    idx = idx_row < 1 | idx_row > size (rgb, 1);
    idx_row(idx) = [];
    alpha(idx,:) = [];
    idx = idx_col < 1 | idx_col > size (rgb, 2);
    idx_col(idx) = [];
    alpha(:,idx) = [];

    ## Insert box
    if (options("boxopacity") > 0)
      for k=1:3
        rgb(idx_row, idx_col, k) = rgb(idx_row, idx_col, k) * ...
            (1-options("boxopacity")) + box_color(i, k) * options("boxopacity");
      endfor
    endif

    ## Insert text
    for k=1:3
      rgb(idx_row, idx_col, k) = rgb(idx_row, idx_col, k) .* (1-alpha) + alpha * text_color(i, k);
    endfor

  endfor

endfunction

function rgb = str2rgb (str)
  str = cellstr (str);
  rgb = zeros (numel (str), 3);
  for i=1:numel (str)
    switch (tolower (str{i}))
      case "blue"
        rgb(i,:) = [0 0 1];
      case "black"
        rgb(i,:) = [0 0 0];
      case "red"
        rgb(i,:) = [1 0 0];
      case "green"
        rgb(i,:) = [0 1 0];
      case "yellow"
        rgb(i,:) = [1 1 0];
      case "magenta"
        rgb(i,:) = [1 0 1];
      case "cyan"
        rgb(i,:) = [0 1 1];
      case "white"
        rgb(i,:) = [1 1 1];
      otherwise
        error ("insertText: invalid color");
    endswitch
  endfor
endfunction

%!test
%! rgb = insertText (rand (64), [8 16], "Octave");
%! rgb = insertText (rand (64, 64, 3), [8 16], "Octave");
%! rgb = insertText (uint8(rand (64, 64) * 255), [8 16], "Octave");
%! rgb = insertText (uint8(rand (64, 64, 3) * 255), [8 16], "Octave");
%! rgb = insertText (rand (64), [8 16], pi);
%! rgb = insertText (rand (64), [8 16], "Octave", "Font", "FreeSerif");
%! rgb = insertText (rand (64), [8 16], "Octave", "FontSize", 42);
%! rgb = insertText (rand (64), [8 16], "Octave", "FontColor", "yellow");
%! rgb = insertText (rand (64), [8 16], "Octave", "FontColor", [1 1 0]);
%! rgb = insertText (rand (64), [8 16], "Octave", "TextColor", [1 1 0]);
%! rgb = insertText (rand (64), [8 16], "Octave", "TextBoxColor", "magenta");
%! rgb = insertText (rand (64), [8 16], "Octave", "TextBoxColor", [1 0 1]);
%! rgb = insertText (rand (64), [8 16], "Octave", "BoxOpacity", 0.4);
%! rgb = insertText (rand (64), [8 16], "Octave", "BoxOpacity", 0);
%! rgb = insertText (rand (64), [8 16], "Octave", "BoxOpacity", 1);
%! rgb = insertText (rand (64), [8 16], "Octave", "AnchorPoint", "Center");
%! rgb = insertText (rand (64), [8 16], repmat ("Octave", 1, 20)); # check crop
%! rgb = insertText (rand (64), [32 16; 32 48], {"GNU","Octave"}, "AnchorPoint", "Center");
%! rgb = insertText (rand (64), [32 16; 32 48], [pi, exp(1)], "AnchorPoint", "Center");
%! rgb = insertText (rand (64), [8 8; 8 32], {"Octave"});
%! rgb = insertText (rand (64), [8 8; 8 32], "Octave", "TextBoxColor", [1 0 0;0 1 0]);
%! rgb = insertText (rand (64), [8 8; 8 32], "Octave", "TextBoxColor", "BlUe");
%! rgb = insertText (rand (64), [8 8; 8 32], "Octave", "TextBoxColor", "white", "FontColor", {"cyan", "green"});

## Test input validation
%!error <Invalid call> insertText ()
%!error <Invalid call> insertText (1)
%!error <Invalid call> insertText (1, 2)
%!error <Invalid call> insertText (1, 2, 3, 4)
%!error [a, b] = insertText (1, 2, 3)
%!error rgb = insertText (rand (64, 64, 3, 3), [8 16], "Octave");
%!error rgb = insertText ([1, 2, 3, 4], [8 16], "Octave");
%!error rgb = insertText (rand (64), [8 16], "Octave", "Font", 12);
%!error rgb = insertText (rand (64), [8 16], "Octave", "FontSize", "12");
%!error rgb = insertText (rand (64), [8 16], "Octave", "FontColor", [1 2 3 4]);
%!error rgb = insertText (rand (64), [8 16], "Octave", "TextColor", [1 2 3 4]);
%!error rgb = insertText (rand (64), [8 16], "Octave", "TextBoxColor", "pink");
%!error rgb = insertText (rand (64), [8 16], "Octave", "BoxOpacity", 1.2);
%!error rgb = insertText (rand (64), [8 16], "Octave", "AnchorPoint", "Middle");
%!error rgb = insertText (rand (64), [8 16], "Octave", "FontWeight", "bold");
%!error rgb = insertText (rand (64), [8 8; 8 32], "Octave", "TextBoxColor", eye(3));
%!error rgb = insertText (rand (64), [8 8; 8 32], "Octave", "FontColor", eye(3));
%!error rgb = insertText (rand (64), [8 8; 8 32], "Octave", "TextColor", zeros(3));

