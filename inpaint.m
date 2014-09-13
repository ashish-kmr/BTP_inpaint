function [ img,init_img ] = inpaint()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% 300 - 310, 450 - 480
% inpainting average values
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
       	   if (k==q(id,2) &&  l==q(id,3)) || (k~=q(id,2) && l~=q(id,3))
               continue;
           end
           %disp(k)
           %disp(l)
           if flag(k,l)==0
               continue;
           end
           if flag(k,l)==2
               flag(k,l)=1;
               [pix_val]=inpaint_pixel(img,k,l,flag,T);
               img(k,l)=pix_val;
           end
           
           w1=solve(T,flag,k-1,l,k,l-1);           
           w2=solve(T,flag,k-1,l,k,l-1);
           w3=solve(T,flag,k-1,l,k,l+1);
           w4=solve(T,flag,k+1,l,k,l+1);
           T(k,l)=minOf4(w1,w2,w3,w4);
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



function [pix] = inpaint_pixel(img,i,j,flag,T)
        %i
        %j
        
        %k=img(i,j)
        %'sss'
        
        %disp('inpainting')
        %pause;
        Ia=0;
        s=0;
        for k=i-10:i+10
            for l=j-10:j+10
                t=img(k,l);
                
                
           %disp(k)
           %disp(l)
               if (flag(k,l)==2)  % change ; wrong in book
                   %disp('Case 2 break')
                   continue;
               end
               gradx=[T(i+1,j)-T(i-1,j)]/2;
               grady=[T(i,j+1)-T(i,j-1)]/2;

              %r = vector from (i,j) to (k,l);
              rx=k-i;
              ry=l-j;
              len=sqrt(rx*rx+ry*ry);
              dir = (rx*gradx+ry*grady)/len;
              dst = 1/(len*len);
              if T(k,l)>=T(i,j)
                  lev = 1/(1+(T(k,l)-T(i,j)));
              else
                  lev = 1/(1+(T(i,j)-T(k,l)));
              end    
              %'ashish'
              %dst
              %dir
              %lev
              w = dir*dst*lev;
              %'ashish'
              
              if w<0
                  w=w*(-1);
              end
                  
              
              if flag(k+1,l)~=2 && flag(k-1,l)~=2 && flag(k,l+1)~=2 && flag(k,l-1)~=2   %chaneg
                  gradIx = [img(i+1,j)-img(i-1,j)]/2;
                  gradIy = [img(i,j+1)-img(i,j-1)]/2;
                     
                  Ia = Ia + (w * img(k,l) + gradIx * rx + gradIy*ry);
                  s = s + w;

            end
            end
        end
        
                %'smriti'
                pix = Ia/s;
                %w
                
                %'smriti'
                
                
                
end
function [sol] = solve(T,flag,i1,j1,i2,j2)
        sol=1000000;
        
        if flag(i1,j1)==0
            if flag(i2,j2)==0
                r=sqrt(2*T(i1,j1)*T(i2,j2)*T(i1,j1)*T(i2,j2));
                s=(T(i1,j1)+T(i2,j2)*r)/2;
                if (s>=T(i1,j1) && s>=T(i2,j2))
                    sol=s;
                else
                    s=s+r;
                    if (s>=T(i1,j1) && s>=T(i2,j2))
                        sol = s;
                    end
                end
            else
                sol=1+T(i1,j1);
            end
        else
            if flag(i2,j2)==0
                sol=1+T(i2,j2);
            end
        end
        
end
                     
                    
                     
                     


