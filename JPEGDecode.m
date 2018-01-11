function imgint = JPEGDecode( code,width,height)
%JPEGDECODE �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
load ACpara.mat

truerow = height/8; %8*8��С��
truecol = width/8;
isBlockStart = 1; %�ж��Ƿ���ÿһ����Ŀ�ʼ
BlockPoint = 1; %��ǰ���ڿ��е�λ��
BlockRow = 1; %���������˶����и���
BlockCol = 1; %���������˶����и���
intBlock = []; %������1*64����
DCFomer = 0; %����ǰһ���DC����
DCLen = 0; %ֱ�������ߴ�
ACLen = 0; %��ǰ���������ߴ�
for k = 1 : 64
    intBlock(k) = 0; %ȫ���㣬���ķ���ֵ
end
i = 1; %�������������ַ�������λ��
j = 1; %��������ƫ��

while 1
    if isBlockStart == 1 %�ǿ鿪ͷ�����DC���������������AC����
        i = i + DCLen + ACLen;
        if (i >= length(code))
            break;
        end
        ACLen = 0;
        j = 1;
        DCcode = '';
        dcint = []; %����int�ͱ���
        while 1 %��ͣѰ�����֣�ֱ�����ֳ��֣����н���DC���������˳�ѭ��
            id = ismember(DC,code(i:i + j));
            [m,n] = find (id == 1); %Ѱ������
            if isempty(m)
                j = j + 1;
            else
                DCPre = code(i:i + j); %ǰ׺��
                DCLen = DClength(n); %�ߴ�
                if DCLen == 0
                    DCpara = 0;
                    break
                end
                DCcode(1,1:DCLen) = code(i + j + 1:i + j + DCLen); %β��
                DCpara = 0; %��������ʮ������ֵ
                for m = 1 : DCLen %תΪintֵ
                    dcint(m) = str2num(DCcode(m));
                end
                if dcint(1) == 1 %�ж�����
                    for m = 1:DCLen
                        DCpara = DCpara + dcint(m) * 2 ^ (DCLen - m);
                    end
                else
                    for m = 1:DCLen
                        if dcint(m) == 0
                            dcint(m) = 1;
                        else
                            dcint(m) = 0;
                        end
                        DCpara = DCpara + dcint(m) * 2 ^ (DCLen - m);
                    end
                    DCpara = -DCpara;
                end
                break
            end
        end
        isBlockStart = 0;
        BlockPoint = BlockPoint + 1;
        intBlock(1) = DCpara + DCFomer;
        DCFomer = intBlock(1);
        
    else
        i = i + j + DCLen + ACLen + 1;
        if (i >= length(code))
            break;
        end
        DCLen = 0;
        ACcode = '';
        acint = [];
        j = 1;
        while 1
            id = ismember(AC,code(i:i + j));
            [m,n] = find (id == 1);
            if isempty(m)
                j = j + 1;
            elseif m == 1 & n == 1 %Ϊ������
                BlockPoint = 64;
                ACLen = 4;
                ACpara = 0;
                runlength = 0;
                break
            elseif m == 16 & n == 1 %Ϊ������
                runlength = 15;
                ACpara = 0;
                ACLen = 0;
                break;
            else
                ACPre = code(i:i + j);
                runlength = m - 1;
                ACLen = AClength(n - 1);
                ACcode(1,1:ACLen) = code(i + j + 1:i + j + ACLen);
                ACpara = 0;
                for m = 1 : ACLen
                    acint(m) = str2num(ACcode(m));
                end
                if acint(1) == 1
                    for m = 1:ACLen
                        ACpara = ACpara + acint(m) * 2 ^ (ACLen - m);
                    end
                else
                    for m = 1:ACLen
                        if acint(m) == 0
                            acint(m) = 1;
                        else
                            acint(m) = 0;
                        end
                        ACpara = ACpara + acint(m) * 2 ^ (ACLen - m);
                    end
                    ACpara = -ACpara;
                end
                break
            end
        end
%         intBlock(BlockPoint : BlockPoint + runlength) = 0;
        intBlock(BlockPoint + runlength) = ACpara;
        if BlockPoint == 64
            isBlockStart = 1;
            BlockPoint = 0;
            q = invZigzag(intBlock); %zigzag���任
            dct = JPEGiQuantification(q); %������
            blockint = JPEGiDCT(dct); %��DCT
            blockint = round(blockint); %ȡ��
            imgint((BlockRow-1)*8+1:BlockRow*8,(BlockCol-1)*8+1:BlockCol*8) = blockint; %�洢����ֵ
            if BlockCol == truecol
                BlockCol = 1;
                if BlockRow == truerow
                    break %ֱ���к��н�����������ѭ��
                end
                BlockRow = BlockRow + 1;
            else
                BlockCol = BlockCol + 1;
            end
            intBlock(1:64) = 0;
            BlockRow,BlockCol
        end 
        BlockPoint = BlockPoint + runlength + 1;
    end
    if (i >= length(code))
        break;
    end
end

[width,height] = size(imgint);
for i = 1 : width
    for j = 1 : height
        if imgint(i,j) < 0
            imgint(i,j) = 0; %��ֵ����
        end
    end
end
imgint = uint8(imgint); %ת��uint8������ʾ��ͼ��
