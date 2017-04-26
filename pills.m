clear;
img = imread('1.tiff');
gray = rgb2gray(img);
bw = im2bw(img, graythresh(gray));
bw = imfill(bw, 'holes');
se0 = strel('disk',5);
bw = imopen(bw, se0);  %二值图像处理，修剪药板区域
%imshow(bw);
gray = uint8(bw).*gray;  %利用二值图像剪裁灰度图像
img = cat(3,uint8(bw).*img(:,:,1),uint8(bw).*img(:,:,2),uint8(bw).*img(:,:,3));  %利用二值图像剪裁rgb图像
%result 1
e = edge(bw,'canny');
theta = 1:180;
[R,xp] = radon(e,theta);
[I,J] = find(R>=max(max(R)));%J记录了倾斜角，最大的倾斜角
angle=90-J;
bw = imrotate(bw,angle,'bicubic','crop');
gray = imrotate(gray,angle,'bicubic','crop');
img = imrotate(img,angle,'bicubic','crop');
e = imrotate(e,angle,'bicubic','crop');
%旋转二值、灰度、彩色图像和边缘

se1 = strel('disk',6);
se2 = strel('disk',2);
sedge = imdilate(e,se1);
sedge = sedge .* bw;
sedge = imerode(sedge,se2);
%imshow(sedge);
dimg = im2double(img);

[x,y] = find(sedge == 1);
region = zeros(size(gray));  %region:药板区域
limit = length(x) * 0.03;  %最终剩余点所占百分比
while length(x) > limit
  randco = ceil(rand(1)*length(x));
  seedx = x(randco);
  seedy = y(randco);
  J = regiongrowing(dimg,0.1,seedx,seedy);
  region = region + J(:,:,1);
  sedge = sedge - region;
  [x,y] = find(sedge == 1);
end
region = logical(region);

%对药板区域进行二值处理
se3 = strel('disk',5);
region = imclose(region, se3);
se4 = strel('disk',3);
ebw = imerode(bw,se4);  %将二值图像腐蚀掉一些边缘像素
pill = ebw - region;
pill(pill<0) = 0;
pill = logical(pill);
se5 = strel('disk',3);
pill = imerode(pill,se5);  %适当缩小最终药丸区域的大小
imshow(pill);
imshow(img);

[l,num]=bwlabel(pill,8);
status = regionprops(l,'BoundingBox');  %%画外接矩形
hold on;
for i = 1 : num
     rectangle('position',status(i).BoundingBox,'edgecolor','r');
end 
hold off;
