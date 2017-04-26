clear;
img = imread('1.tiff');
gray = rgb2gray(img);
bw = im2bw(img, graythresh(gray));
bw = imfill(bw, 'holes');
se0 = strel('disk',5);
bw = imopen(bw, se0);  %��ֵͼ�����޼�ҩ������
%imshow(bw);
gray = uint8(bw).*gray;  %���ö�ֵͼ����ûҶ�ͼ��
img = cat(3,uint8(bw).*img(:,:,1),uint8(bw).*img(:,:,2),uint8(bw).*img(:,:,3));  %���ö�ֵͼ�����rgbͼ��
%result 1
e = edge(bw,'canny');
theta = 1:180;
[R,xp] = radon(e,theta);
[I,J] = find(R>=max(max(R)));%J��¼����б�ǣ�������б��
angle=90-J;
bw = imrotate(bw,angle,'bicubic','crop');
gray = imrotate(gray,angle,'bicubic','crop');
img = imrotate(img,angle,'bicubic','crop');
e = imrotate(e,angle,'bicubic','crop');
%��ת��ֵ���Ҷȡ���ɫͼ��ͱ�Ե

se1 = strel('disk',6);
se2 = strel('disk',2);
sedge = imdilate(e,se1);
sedge = sedge .* bw;
sedge = imerode(sedge,se2);
%imshow(sedge);
dimg = im2double(img);

[x,y] = find(sedge == 1);
region = zeros(size(gray));  %region:ҩ������
limit = length(x) * 0.03;  %����ʣ�����ռ�ٷֱ�
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

%��ҩ��������ж�ֵ����
se3 = strel('disk',5);
region = imclose(region, se3);
se4 = strel('disk',3);
ebw = imerode(bw,se4);  %����ֵͼ��ʴ��һЩ��Ե����
pill = ebw - region;
pill(pill<0) = 0;
pill = logical(pill);
se5 = strel('disk',3);
pill = imerode(pill,se5);  %�ʵ���С����ҩ������Ĵ�С
imshow(pill);
imshow(img);

[l,num]=bwlabel(pill,8);
status = regionprops(l,'BoundingBox');  %%����Ӿ���
hold on;
for i = 1 : num
     rectangle('position',status(i).BoundingBox,'edgecolor','r');
end 
hold off;
