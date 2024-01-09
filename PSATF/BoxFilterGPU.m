function f = BoxFilterGPU(I, fr)
if (fr == 0)
    f = I;
    return;
end
[h, w, ~] = size(I);
p_I = padarray(I, [fr fr], 'symmetric');
f = gpuArray(zeros(size(I)));
pu = fr+1;
pb = pu+h-1;
pl = fr+1;
pr = pl+w-1;
for x = -fr:fr
    for y = -fr:fr
        f = f + p_I(pu+y:pb+y, pl+x:pr+x, :) ;
    end
end
boxSize = (2*fr+1)*(2*fr+1);
f = f./boxSize;
end