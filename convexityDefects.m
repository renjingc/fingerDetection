function [result]=convexityDefects(ptr,hptr,image)
　　　　%获取图像的高和宽，通道
    [rows,cols,channels]=size(image);
　　　　%获取轮廓的点数
    npoints=length(ptr);
　　　　%获取凸包的点数
    hpoints=length(hptr);
　　　　%检测到的结果，第一列为凸缺陷的开始点，第二个为凸缺陷的结束点，第三个为凸缺陷的凹点，第四个为凹点距离开始和结束线的距离
    defects=zeros(hpoints,4);
　　　　%只有轮廓点数大于3时，才进行下去
    if npoints>3
        num=1;
        hcurr=hptr(1);
	％判断凸包点集的顺序
        if ((hptr(2) > hptr(1)) + (hptr(3) > hptr(2)) + (hptr(1) > hptr(3))) ~= 2
            rev_orientation=1;
        else
            rev_orientation=0;
        end
	%当凸包点集为顺序时，则从第一个凸包点开始遍历
        if rev_orientation==1
            hcurr=hptr(1);
	%当凸包点集为逆序时，则从最后一个凸包点开始遍历        
	else
            hcurr=hptr(hpoints);
        end
	％开始遍历凸包点
        for i = 1:hpoints
	　　　　%下一个凸包点
            hnext=hptr(hpoints-i+1);
	　　　　%当凸包点集为顺序时，则下一个凸包点是从尾开始
            if rev_orientation==1
                hnext=hptr(hpoints-i+1);
	　　　　%当凸包点集为逆序时，则下一个凸包点是从头开始
            else
                hnext=hptr(i);
            end
	　　　　%计算这两个凸包点的x和y的距离，和直线距离为1/scale
            pt0 = ptr(hcurr,:);
            pt1 = ptr(hnext,:);
            dx0 = pt1(2) - pt0(2);
            dy0 = pt1(1) - pt0(1);
            scale=0.0;
            if dx0 == 0 && dy0 == 0
                scale=0.0;
            else
                scale=1./sqrt(dx0*dx0 + dy0*dy0);
            end
　　　　　　　　　　　　%凹点的下标
            defect_deepest_point = -1;
　　　　　　　　　　　　%凸缺陷的深度
            defect_depth = 0;
	    %判断是否检测到凸缺陷的标志位
            is_defect = 0;

	    %遍历轮廓点
            j=hcurr;
            while(1)
                j=j+1;
                tempj=0;
		%如果大于了轮廓点数，则从头遍历
                if j>npoints
                    j=1;
    %             else
    %                 tempj=-1;
                end
    %             j =j & tempj;
		%当j等于下一个凸包点时，则跳出
                if j == hnext
                    break;
                end
		%计算凹点和凸包起始点的x和y距离
                dx = ptr(j,2) - pt0(2);
                dy = ptr(j,1) - pt0(1);
                dist = abs(-dy0*dx + dx0*dy) * scale;
		
		%存储最大的深度，和对应的凹点
                if dist > defect_depth
                    defect_depth = dist;
                    defect_deepest_point = j;
                    is_defect = true;
                end
            end
	　　　　%如果检测到凸缺陷，则加入检测结果
            if is_defect
                idepth = round(defect_depth*256);
                defects(num,1)=hcurr; 
                defects(num,2)=hnext; 
                defects(num,3)=defect_deepest_point;
                defects(num,4)=idepth;
                num=num+1;
            end
            hcurr = hnext;
        end
    end
　　　　
    resultMum=0;
    figure(5), imshow(image), title('original image');
    hold on;
    %筛选，筛选条件为当凸缺陷的深度>20且<200时，并且凸包点不在图像边缘时，则为手指尖点
　　　　for i=1:length(defects)
        dist=defects(i,4)/256;
        if defects(i,1)~=0 && defects(i,2)~=0 && dist>20 && dist<200 && ptr(defects(i,1),1)>3 && ptr(defects(i,1),1)<(cols-3) && ptr(defects(i,1),2)>3 && ptr(defects(i,1),2)<(rows-3)
            resultMum=resultMum+1;
        end
    end
    %将结果通过result返回，并显示
　　　　resultCount=1;
    result=zeros(resultMum,2);
    for i=1:length(defects)
        dist=defects(i,4)/256;
        if defects(i,1)~=0 && defects(i,2)~=0 && dist>20 && dist<200 && ptr(defects(i,1),1)>3 && ptr(defects(i,1),1)<(cols-3) && ptr(defects(i,1),2)>3 && ptr(defects(i,1),2)<(rows-3)
            result(resultCount,1)=ptr(defects(i,1),1);
            result(resultCount,2)=ptr(defects(i,1),2);
            resultCount=resultCount+1;
            plot(ptr(defects(i,1),1),ptr(defects(i,1),2),'.','markersize',30);
        end
    end
