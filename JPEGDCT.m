function X = JPEGDCT(x)
[rows,cols] = size(x);
c = [1/sqrt(2) 1 1 1 1 1 1 1];

% for k = 1:rows
%     for l = 1:cols
%         sum = 0;
%         for m = 1:rows
%             for n = 1:cols
%                 sum = sum + x(m,n) * cos((2 * (m-1) + 1) * (k-1) * pi/16) * cos((2 * (n-1) + 1) * (l-1) * pi/16);
%             end
%         end
%         X(k,l) = 0.25 * c(k) * c(l) * sum;
%     end
% end

for i = 1:rows
    for j = 1:cols
        A(i,j) = sqrt(2/rows) * c(i) * cos(((j- 1) + 0.5) * pi * (i-1) / rows);
    end
end

X = A * x * A';