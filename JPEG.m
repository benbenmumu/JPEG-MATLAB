function [code,psnr,ratio] = JPEG( img )
%JPEG 输入
%   此处显示详细说明

imgint = imread(img); %读图片矩阵
[row,col] = size(imgint); %图片矩阵的大小
rows = row / 8; %8个像素为一块
cols = col / 8;
lastcode = ''; %存储最终编码字符串

%编码每个块
block = []; %存放8*8块
FormerDC = 0; %前一块的直流系数，编码第一块的时候为0
for k = 1:rows
    for l = 1:cols
        block(1:8,1:8) = imgint((k-1)*8+1:k*8,(l-1)*8+1:l*8);
        dct = JPEGDCT(block); %dct变换
        q = JPEGQuantification(dct); %量化
        zz = Zigzag(q); %zigzag
        strcode = JPEGEncode(zz,FormerDC); %编码
        lastcode = [lastcode,strcode];
        FormerDC = zz(1);
        k,l
    end
end
code = lastcode;

img = JPEGDecode(code,col,row); %解码
subplot(1,2,1)
imshow(imgint)
title('原始图像')
subplot(1,2,2)
imshow(img)
title('恢复图像')

sumsq = 0; %平方误差
for i = 1 : row
    for j = 1 : col
        x = double(img(i,j)-imgint(i,j)+1.0-1.0);
        sq = x ^ 2;
        sumsq = sumsq + sq; %计算平方误差
    end
end
mse = sumsq / (row * col); %计算均方误差
psnr = 20 * log10(255/sqrt(mse)) %计算峰值信噪比

ratio = length(code)\(row * col * 8) %计算压缩比