function [result]=finger(image)
    %显示原图
    %将原图转换到ycbcr空间
    J = rgb2ycbcr(image);
    Y =J(:,:,1);
    Cb =J(:,:,2);
    Cr =J(:,:,3);
    %肤色判断，即Cb>=100&Cb<=127 Cr>=138&Cr<=170的像素点为皮肤
    I =[(Cb>=100 & Cb<=127) & (Cr>=138 & Cr<=170)];

    %对二值图像的形态学操作,先进行dilate膨胀，再erode腐蚀
    I = bwmorph(I,'dilate');
    I = bwmorph(I,'erode');
    %填充二值图像中的空洞区域。 如， 黑色的背景上有个白色的圆圈。 则这个圆圈内区域将被填充。
    I = imfill(I,'holes');

    %显示过滤后的二值图像
    figure(2), imshow(I), title('filtered & binarized image');

　　　　%提取图像的canny边缘
    BW1 = edge(I,'canny');
　
　　　　%提取图像的轮廓，B为轮廓，L为标注矩阵
    [B,L] = bwboundaries(BW1,'noholes');

　　　　%第二种提取轮廓的方法，这里没有用到
    b=boundaries(I,4,'cw');
    d=cellfun('length',b);
    [max_d,k]=max(d);
    v=b{k(1)};
    % b=b{1};
    [M,N]=size(I);
    xmin=min(v(:,1));
    ymin=min(v(:,2));
    [x,y]=minperpoly(I,3);%使用大小为2的方形单元
    b2=connectpoly(x,y);
    B2=bound2im(b2,M,N,xmin,ymin);

　　　　%提取图像的各种信息
    img_reg =regionprops(L,'All');

　　　　%提取周长最大的轮廓
    maxLength=0;maxK=1;
    % 循环历遍每个连通域的边界
    for k = 1:length(B)
      % 获取一条边界上的所有点
      boundary = B{k};
      % 计算边界周长
      delta_sq = diff(boundary).^2;    
      perimeter = sum(sqrt(sum(delta_sq,2)));
      % 获取边界所围面积
      area = img_reg(k).Area;
      if perimeter>maxLength
          maxLength=perimeter;
          maxK=k;
      end
    end　
　　　　%轮廓周长最长的为手的轮廓
    boundary = B{maxK};

　　　　%提取手轮廓的凸多边形，返回的是轮廓数组中的下标
    hull=myConvexHull(boundary(:,2),boundary(:,1));  
    %hull=myConvexHull(x,y);  

　　　　%获取手的轮廓
    ptr=[boundary(:,2),boundary(:,1)];
    %ptr=[y,x];%;b2;
　　　　%获取手轮廓的凸多边形
    hptr=hull;

　　　　%将手的轮廓和凸多形性输入，检测手的凸缺陷，即两手指尖的凹处
    result=convexityDefects(ptr,hptr,image);
