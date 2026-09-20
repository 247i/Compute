## Copyright (C) 2014-2026 Philip Nienhuis
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
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
## @deftypefn {Function File} {@var{ftype} =} __get_ftype__ (@var{fname})
## Get file type index from a file name, based on the file extension.
##
## @var{ftype} is set to 0 (zero) for any other file type.
## @var{ftype} is set to empty for file names without extension.
## In those cases filtnam is set to empty
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2014-01-01

function [ftype, filtnam, ext] = __get_ftype__ (fname)

  persistent filtnams;
  filtnams = {"MS Excel 97",                        ##  1 .xls
              "Calc MS Excel 2007 XML",             ##  2 .xlsx
              "calc8",                              ##  3 .ods
              "StarOffice XML (Calc)",              ##  4 .sxc
              "Gnumeric Spreadsheet",               ##  5 .gnumeric, .gnm
              "Text CSV",                           ##  6 .csv
              "UOF spreadsheet",                    ##  7 .uos
              "OpenDocument Spreadsheet Flat XML",  ##  8 .fods
              "dBase",                              ##  9 .dbf
              "DIF",                                ## 10 .dif
              "Lotus",                              ## 11 .wk1 .wk2 .123
              "WPS_Lotus_Calc",                     ## 12 .wk3 .wk4
              "MS_Works_Calc",                      ## 12 .wks, .wdb
              "ClarisWorks_Calc",                   ## 14.cwk
              "Mac_Works_Calc",                     ## 15 .wps
              "Quattro Pro 6.0",                    ## 16 .wb2
              "WPS_QPro_Calc",                      ## 17 .wb1 .wq1 .wq2
              "Rich Text Format (StarCalc)",        ## 18 .rtf
              "SYLK",                               ## 19 .slk .sylk
              "Apple Numbers",                      ## 20 .numbers
              "Microsoft Multiplan"};               ## 21 .mp


  [~, ~, ext] = fileparts (fname);
  if (! isempty (ext))
    switch lower (ext)
      case ".xls"                       ## Regular (binary) BIFF
        ftype = 1;
      case {".xlsx", ".xlsm", ".xlsb"}  ## Zipped XML / OOXML. Catches xlsx, xlsb, xlsm
        ftype = 2;
      case ".ods"                       ## ODS 1.2 (Excel 2007+ & OOo/LO can read ODS)
        ftype = 3;
      case ".sxc"                       ## old OpenOffice.org 1.0 Calc
        ftype = 4;
      case {".gnumeric", ".gnm"}        ## Zipped XML / gnumeric
        ftype = 5;
      case ".csv"                       ## csv. Detected for xlsread afficionados
        ftype = 6;
      case ".uof"                       ## Unified Office Format
        ftype = 7;
      case ".fods"                      ## ODS Flat HTML
        ftype = 8;
      case ".dbf"                       ## Dbase
        ftype = 9;
      case ".dif"                       ## Digital Interchange Format
        ftype = 10;
      case {".wk1", ".wk2", ".123"}     ## Lotus
        ftype = 11;
      case {".wk3", ".wk4"}             ## WPS_Lotus_Calc
        ftype = 12;
      case {".wks", ".wdb"}             ## MS_Works_Calc
        ftype = 13;
      case ".cwk"                       ## ClarisWorks_Calc
        ftype = 14;
      case ".wps"                       ## Mac_Works_Calc
        ftype = 15;
      case ".wb2"                       ## Quattro Pro 6.0
        ftype = 16;
      case {".wb1", ".wq1", ".wq2"}     ## WPS_QPro_Calc
        ftype = 17;
      case ".rtf"                       ## Rich Text Format (StarCalc)
        ftype = 18;
      case {".slk", ".sylk"}            ## SYLK
        ftype = 19;
      case ".numbers"                   ## Apple Numbers
        ftype = 20;
      case ".mp"                        ## Microsoft Multiplan
        ftype = 21;
      otherwise                         ## Any other type = non-supported
        ftype = 0;
    endswitch
  else
    ftype = "";
  endif

  if (ftype > 0)
    filtnam = filtnams{ftype};
  else
    filtnam = "";
  endif

endfunction
