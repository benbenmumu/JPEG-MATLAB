function ZZ = Zigzag( zz )
%ZIGZAG 此处显示有关此函数的摘要
%   此处显示详细说明

index=reshape(1:numel(zz),size(zz));
index=fliplr(spdiags(fliplr(index)));
index(:,1:2:end)=flipud(index(:,1:2:end));
index(index==0)=[];
ZZ=zz(index);

end
