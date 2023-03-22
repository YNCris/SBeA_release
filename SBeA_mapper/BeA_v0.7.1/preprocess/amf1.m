function output = amf1(input,maxwindow)
% global noise suppression by adaptive median filtering
%
% Input
%   input         -  vector of input data, N x 1 (vector)
%   maxwindow     -  maximum window width, 1 x 1 (integral)
%
% Output
%   output        -  vector of output data, N x 1 (vector)
%
% History
%   create  -  Yaning Han  (yn.han@siat.ac.cn), 03-03-2020

%% AMF
Nmax = maxwindow;
img = input;
m=size(img,1);
imgn=zeros(m+2*Nmax,1);   
imgn(Nmax+1:m+Nmax,:)=img;  
imgn(1:Nmax,1)=img(1:Nmax,1);            
imgn(m+Nmax+1:m+2*Nmax,1)=imgn(m+1:m+Nmax,1);  
re=imgn; 
for i=Nmax+1:m+Nmax
        r=1;             
        while r~=Nmax+1   
            W=imgn(i-r:i+r,1);
            W=sort(W(:));       
            Imin=min(W(:));       
            Imax=max(W(:));        
            Imed=median(W);    
            if Imin<Imed && Imed<Imax      
               break;
            else
                r=r+1;           
            end          
        end             
        if Imin<imgn(i,1) && imgn(i,1)<Imax        
            re(i,1)=imgn(i,1);
        else                                     
            re(i,1)=Imed;
        end
end
output = re((1+Nmax):(end-Nmax),1);