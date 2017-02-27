function indexXY=myConvexHull(x,y)

%构成四边形边界
n=length(x);
%最小最大的x和y坐标
ix=min(x);
iy=min(y);
ax=max(x);
ay=max(y);

%检测点集，删去内部点，留下可能构成最小凸包的点
test=(x>=ix | x<=ax | y>=iy | y<=ay);
index=1:n;
index=(index(test));
%可能构成最小凸包的点
x=x(test);
y=y(test);
%可能构成最小凸包的点数
n=length(x);

%按y值由小到大排序
[y,sindex] = sort(y);
x = x(sindex);

temp=zeros(n,1);

%共线问题，删去共线的点
%及假设几点是在同一条线上，则只取改线的两端点作为凸包点
colinear=false;
if y(1)==y(2) || y(end)==y(end-1)
    i=1;
    while y(i)==y(i+1)
        i=i+1;
    end
    if i>2
    %计算求得输入点x坐标最小（如果x相等，则比较y是不是最小）的点，作为第一个点
    [x(1:i),xid]=sort(x(1:i),'descend');
    tempindex=sindex(xid);
    sindex(1:i)=tempindex; 
    sindex(2:i-1)=[];
    y(2:i-1)=[];
    x(2:i-1)=[];
    end
    i=1;
    if x(1)>x(2)
       while y(end-i+1)==y(end-i)
            i=i+1;
        end
        if i>1
      
         colinear=true;
        [x(end-i+1:end),xid]=sort(x(end-i+1:end),'ascend');
        tempindex=sindex(end-i+1:end);
        sindex(end-i+1:end)=tempindex(xid);
        
        sindex(end-i+2:end-1)=[];
        x(end-i+2:end-1)=[];
        y(end-i+2:end-1)=[];
        end
        
    else
        while y(end-i+1)==y(end-i)
            i=i+1;
        end
        if i>1
         
         colinear=true;
        [x(end-i+1:end),xid]=sort(x(end-i+1:end),'descend');
        tempindex=sindex(end-i+1:end);
        sindex(end-i+1:end)=tempindex(xid);
       
        sindex(end-i+2:end-1)=[];
        x(end-i+2:end-1)=[];
        y(end-i+2:end-1)=[];
         end
    end
    n=length(x);
end

%确定方向  
%当x(1)>x(2)，则方向为1
%否则为-1
if x(1)>x(2)
    orientation=1;
else         
    orientation=-1;
end


c=2;
i=2;

temp(1)=1;
temp(2)=2;
p1=temp(1);
p2=temp(2);

while i<=n-1
    p3=i+1;
    cp=orientation*((x(p1)-x(p2))*(y(p3)-y(p2))-(x(p3)-x(p2))*(y(p1)-y(p2)));
    
    if cp>0 
        temp(c+1)=i+1; 
        p1=p2;
        p2=p3;
        c=c+1;
        i=i+1;
    else
        if c>2
            c=c-1;
            p2=p1;
            p1=temp(c-1);
        else
            temp(2)=i+1;
            p2=i+1;
            i=i+1;
        end
    end
end

p1=c-1;
p1=temp(p1);
p2=temp(c);
if colinear || p1==i-1;
    i=i-1;
end

while i>1
   p3=i-1;
   cp=orientation*((x(p1)-x(p2))*(y(p3)-y(p2))-(x(p3)-x(p2))*(y(p1)-y(p2)));
    if cp>0   
       temp(c+1)=i-1;
        p1=p2;
        p2=p3;
        c=c+1;
        i=i-1;
       
    else
        c=c-1;
        p2=p1;
        p1=temp(c-1);
    end
end
indexXY=index(sindex(temp((1:c))))';
end
