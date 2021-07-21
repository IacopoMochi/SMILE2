function I = irresize(path)

I = imread(path);
I = imresize(I,[724,1024],'nearest');