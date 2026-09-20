## Copyright (C) 2024 David Legland
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
## 
##     1 Redistributions of source code must retain the above copyright notice,
##       this list of conditions and the following disclaimer.
##     2 Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in the
##       documentation and/or other materials provided with the distribution.
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
## ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
## CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
## 
## The views and conclusions contained in the software and documentation are
## those of the authors and should not be interpreted as representing official
## policies, either expressed or implied, of the copyright holders.

function transforms3d(varargin)
%TRANSFORMS3D  Conventions for manipulating 3D affine transforms.
%
%   By 'transform' we mean an affine transform. A 3D affine transform
%   is represented by a 4*4 matrix. The last row of the matrix is equal to
%   [0 0 0 1].
%
%   
%
%   Example:
%   % create a translation by the vector [10 20 30]:
%   T = createTranslation3d([10 20 30]);
%   % Transform a basic point:
%   PT1 = [4 5 6];
%   PT2 = transformPoint3d(PT1, T)
%   % returns:
%   PT2 = 
%       14   25   36
%
%   See also 
%   composeTransforms3d, createBasisTransform3d, createRotation3dLineAngle,
%   createRotationAboutPoint3d, createRotationOx, createRotationOy, 
%   createRotationOz, createRotationVector3d, createRotationVectorPoint3d, 
%   createScaling3d, createTranslation3d, eulerAnglesToRotation3d, 
%   fitAffineTransform3d, isTransform3d, recenterTransform3d, 
%   rotation3dAxisAndAngle, rotation3dToEulerAngles
%   transformCircle3d, transformLine3d, transformPlane3d, transformPoint3d, 
%   transformPolygon3d, transformVector3d
%

% ------
% Author: David Legland
% E-mail: david.legland@inrae.fr
% Created: 2008-10-13, using Matlab 7.4.0.287 (R2007a)
% Copyright 2008-2023 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas
