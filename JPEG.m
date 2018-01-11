function [code,psnr,ratio] = JPEG( img )
%JPEG ����
%   �˴���ʾ��ϸ˵��

imgint = imread(img); %��ͼƬ����
[row,col] = size(imgint); %ͼƬ����Ĵ�С
rows = row / 8; %8������Ϊһ��
cols = col / 8;
lastcode = ''; %�洢���ձ����ַ���

%����ÿ����
block = []; %���8*8��
FormerDC = 0; %ǰһ���ֱ��ϵ���������һ���ʱ��Ϊ0
for k = 1:rows
    for l = 1:cols
        block(1:8,1:8) = imgint((k-1)*8+1:k*8,(l-1)*8+1:l*8);
        dct = JPEGDCT(block); %dct�任
        q = JPEGQuantification(dct); %����
        zz = Zigzag(q); %zigzag
        strcode = JPEGEncode(zz,FormerDC); %����
        lastcode = [lastcode,strcode];
        FormerDC = zz(1);
        k,l
    end
end
code = lastcode;

img = JPEGDecode(code,col,row); %����
subplot(1,2,1)
imshow(imgint)
title('ԭʼͼ��')
subplot(1,2,2)
imshow(img)
title('�ָ�ͼ��')

sumsq = 0; %ƽ�����
for i = 1 : row
    for j = 1 : col
        x = double(img(i,j)-imgint(i,j)+1.0-1.0);
        sq = x ^ 2;
        sumsq = sumsq + sq; %����ƽ�����
    end
end
mse = sumsq / (row * col); %����������
psnr = 20 * log10(255/sqrt(mse)) %�����ֵ�����

ratio = length(code)\(row * col * 8) %����ѹ����