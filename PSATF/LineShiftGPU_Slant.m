function [GX, GY, AlphaX, AlphaY] = LineShiftGPU_Slant(E, I, angle, params)

ERot = ImageRotate(E, angle);
IRot = ImageRotate(I, angle);

[GX, GY, AlphaX, AlphaY] = LineShiftGPU(ERot, IRot,  params);

GX = ImageRecovery(I, GX, angle);
GY = ImageRecovery(I, GY, angle);
AlphaX = ImageRecovery(I, AlphaX, angle);
AlphaY = ImageRecovery(I, AlphaY, angle);

end
function imgRot = ImageRotate(img, angle)
[height, width, dim] = size(img);
[xMin, xMax, yMin, yMax] = RotateSize(height, width, angle);
XShift = -xMin + 1;
YShift = -yMin + 1;
rotHeight = xMax + XShift;
rotWidth = yMax + YShift;

imgRot = zeros(rotHeight, rotWidth, dim, 'gpuArray');
[rotY, rotX] = meshgrid(1:rotWidth,1:rotHeight);
rotY = gpuArray(rotY - YShift);
rotX = gpuArray(rotX - XShift);
rocX = rotX.*cosd(angle) + rotY.*sind(angle);
rocY = rotY.*cosd(angle) - rotX.*sind(angle);

rocXFloor = floor(rocX);
rocYFloor = floor(rocY);
rocXCeil = ceil(rocX);
rocYCeil = ceil(rocY);
coffX = rocX - rocXFloor;
coffY = rocY - rocYFloor;

ind = (rocXFloor>=1&rocXFloor<=height&...
rocYFloor>=1&rocYFloor<=width);
ind = ind&(rocXCeil>=1&rocXCeil<=height&...
rocYCeil>=1&rocYCeil<=width);

rocXFloor = rocXFloor(ind);
rocYFloor = rocYFloor(ind);
rocXCeil = rocXCeil(ind);
rocYCeil = rocYCeil (ind);
coffX = coffX(ind);
coffY = coffY(ind);
% img = double(img);
for ii=1:dim
    imgChan = img(:,:,ii);
    imgRotChan = imgRot(:,:,ii);
    imgRotChan(ind) = ...
    bsxfun(@times, imgChan(rocXFloor+(rocYFloor-1)*height), bsxfun(@times, (1-coffX), (1-coffY))) +...
    bsxfun(@times, imgChan(rocXFloor+(rocYCeil-1)*height), bsxfun(@times, (1-coffX), coffY)) +...
    bsxfun(@times, imgChan(rocXCeil+(rocYFloor-1)*height), bsxfun(@times,  coffX, (1-coffY))) +...
    bsxfun(@times, imgChan(rocXCeil+(rocYCeil-1)*height), bsxfun(@times,  coffX, coffY));
    imgRot(:,:,ii) = imgRotChan;
end
end
function imgRoc = ImageRecovery(img, imgRot, angle)
[height, width, ~] = size(img);
[xMin, xMax, yMin, ~] = RotateSize(height, width, angle);
XShift = -xMin + 1;
YShift = -yMin + 1;
rotHeight = xMax + XShift;
[Y, X] = meshgrid(1:width,1:height);
rotX = gpuArray(X.*cosd(angle) - Y.*sind(angle) + XShift);
rotY = gpuArray(X.*sind(angle) + Y.*cosd(angle) + YShift);
rotXFloor = floor(rotX(:));
rotYFloor = floor(rotY(:));
rotXCeil = ceil(rotX(:));
rotYCeil = ceil(rotY(:));
coffX = rotX(:) - rotXFloor;
coffY = rotY(:) - rotYFloor;
imgRoc = zeros(height, width, size(imgRot,3), 'gpuArray');
% imgRot = double(imgRot);
for ii=1:size(imgRot,3)
    imgRocChan = imgRoc(:,:,ii);
    imgRotChan = imgRot(:,:,ii);
    imgRocChan(:) =...
    bsxfun(@times, imgRotChan(rotXFloor+(rotYFloor-1)*rotHeight), bsxfun(@times, (1-coffX), (1-coffY))) +...
    bsxfun(@times, imgRotChan(rotXFloor+(rotYCeil-1)*rotHeight), bsxfun(@times, (1-coffX), coffY)) +...
    bsxfun(@times, imgRotChan(rotXCeil+(rotYFloor-1)*rotHeight), bsxfun(@times,  coffX, (1-coffY))) +...
    bsxfun(@times, imgRotChan(rotXCeil+(rotYCeil-1)*rotHeight), bsxfun(@times,  coffX, coffY));
    imgRoc(:,:,ii) = imgRocChan;
end
end
function [xMin, xMax, yMin, yMax] = RotateSize(height, width, angle)
    X=[1 1 height height];
    Y=[1 width 1 width];
    X_rot = X*cosd(angle)-Y*sind(angle);
    Y_rot = X*sind(angle)+Y*cosd(angle);
    xMin = floor(min(X_rot(:)));
    xMax = ceil(max(X_rot(:)));
    yMin = floor(min(Y_rot(:)));
    yMax = ceil(max(Y_rot(:)));
end