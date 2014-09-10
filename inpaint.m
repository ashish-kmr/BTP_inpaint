function [ img,init_img ] = inpaint( C )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% 300 - 310, 450 - 480
img=imread('cameraman.tif');
x1=300;
x2=310;
y1=450;
y2=480;
dim=size(img);
flag=zeros(dim(1),dim(2));
T=zeros(dim(1),dim(2));
img([300:310],[450:480])=-1;
T([300:310],[450:480])=1000000;
% 0-- known, 1--band, 2-- inside
flag([299:311],[449:481])=1;
flag([300:310],[450:480])=2;
q=zeros(100000,3);
curr=1;
len=1;
for i=1:dim(1)
    for j=1:dim(2)
        if (flag(i,j)==1)
            q(curr,1)=T(i,j);
            q(curr,2)=i;
            q(curr,3)=j;
            curr=curr+1;
            len=len+1;
        end
    end
end
counter=0;
init_img=img;
while(len>0)
   counter=counter+1;
   if counter>100000
       break;
   end
   id=min_val(q,curr);
   %disp(id)
   %disp('values ^ V')
   %disp(curr)
   if id==-1
       break
   end
   q(id,1)=-1;
   len=len-1;
   flag(q(id,2),q(id,3))=0;
   %disp(flag([300:310],[450:480]))
   %pause
   for k=q(id,2)-1:q(id,2)+1
       for l=q(id,3)-1:q(id,3)+1
       	   %if (k==q(id,2) &&  l==q(id,3)) || (k~=q(id,2) && l~=q(id,3))
           %    disp('Case 1 break')
           %    continue;
           %end
           %disp(k)
           %disp(l)
           if flag(k,l)==0
               %disp('Case 2 break')
               continue;
           end
           if flag(k,l)==2
               flag(k,l)=1;
               [pix_val]=inpaint_pixel(img,k,l,flag);
               img(k,l)=pix_val;
           end
           %T(k,l)=minOf4(solve(k-1,l,k,l-1),solve(k+1,l,k,l-1),solve(k-1,l,k,l+1),solve(k+1,l,k,l+1));
           T(k,l)=T(i,j)+1;
           [q,curr]=insertPQ(q,curr,T(k,l),k,l);
           len=len+1;
       end
   end
       
end

end


function [ b ] = min_val( a , len )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%disp(a([1:len]))
b=-1;
minm=10000000;
for i=1:len-1
    if a(i,1)==-1
        continue
    end
    if a(i,1)<minm
        minm=a(i,1);
        b=i;
    end
end
end

function [q, curr ] = insertPQ( q1, curr1, T_val, k, l )

test=1; 
for it=1:curr1
       if q1(it,1)==-1
           q1(it,1)=T_val;
           q1(it,2)=k;
           q1(it,3)=l;
           test=0;
           curr=curr1;
           break
       end
end
if test==1
       q1(curr1,1)=T_val;
       q1(curr1,2)=k;
       q1(curr1,3)=l;
       curr=curr1+1;
end
q=q1;
end

function [min_v] = minOf4(a,b,c,d)
      min_v=a;
      if b<min_v
          min_v=b;
      end
      if c<min_v
          min_v=c;
      end
      if d<min_v
          min_v=d;
      end
end


function [pix] = inpaint_pixel(img,k,l,flag)
        %disp('inpainting')
        %pause;
        pix=0;
        cnt=1;
        if flag(k-1,l)~=2
            pix=pix+img(k-1,l);
            cnt=cnt+1;
        end
        if flag(k+1,l)~=2
            pix=pix+img(k+1,l);
            cnt=cnt+1;
        end
        if flag(k,l-1)~=2
            pix=pix+img(k,l-1);
            cnt=cnt+1;
        end
        if flag(k,l+1)~=2
            pix=pix+img(k,l+1);
            cnt=cnt+1;
        end
        
        if cnt>2
            cnt=2;
        end
        pix=pix/cnt;
end




