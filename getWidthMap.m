function [Xmap,objectWidthMaps] = getWidthMap(annotation,img,Zmap,objectDepthMaps)
% Xmap = getWidthMap(annotation,img)
%
% Computes width map given the computed 3D mesh.
%
% Inputs:
%   annotation - LabelMe annotation structure
%   img - Corresponding image
%
% Outputs:
%   Xmap - Width map
%   objectWidthMaps - 3D matrix containing widths of the individual
%   objects.

if nargin < 4
  [Zmap,objectDepthMaps] = getDepthMap(annotation,img);
end

MAX_WIDTH = 16777215;
Nobjects = length(annotation.object);
[nrows,ncols,dim] = size(img);

[mx,my] = meshgrid([1:ncols],[1:nrows]);
Xmap = MAX_WIDTH*ones(nrows,ncols,'uint32');
if nargout>=2
  objectWidthMaps = MAX_WIDTH*ones(nrows,ncols,Nobjects,'uint32');
end
for i = 1:Nobjects
  if isfield(annotation.object(i),'mesh') && ~isempty(annotation.object(i).mesh)
    [X,Y] = getLMpolygon(annotation.object(i).polygon);
    v2D = annotation.object(i).mesh.v2D;
    v3D = annotation.object(i).mesh.v3D;
    n = find(inpolygon(mx,my,X,Y));
    x = uint32(griddata(v2D(1,:),v2D(2,:),v3D(1,:),mx(n),my(n)));
    if nargout>=2
      objectWidthMaps(n+(i-1)*nrows*ncols) = x;
    end
    z = objectDepthMaps(:,:,i);
    j = find(Zmap(n)==z(n));
    Xmap(n(j)) = x(j);
  end
end

if nargout==0
  plotDepthMap(Xmap);
end
