function [leadingEdgeProfiles,trailingEdgeProfiles] = edgeDetectfPolyMC(leadingEdges,trailingEdges,Arc,b,threshold)
%polynomial fitting 

leadingEdgeProfiles = zeros(size(Arc,1),length(leadingEdges));
trailingEdgeProfiles = zeros(size(Arc,1),length(trailingEdges));
for n = 1:length(leadingEdges)
    LEn = leadingEdges(n);
    TEn = trailingEdges(n);
    parfor m = 1:size(Arc,1)
        s1 = max(LEn-b,1);
        s2 = min(LEn+b,size(Arc,2));
        
        Arcl = Arc(m,s1:s2);
        %Arcl = smooth(Arc(m,s1:s2));
        
        segm = Arcl;
        %         p = find(segm>threshold,1,'first');
        %         if isempty(p)
        %             leadingEdgeProfiles(m,n)=nan;
        %         elseif (p == s2-s1+1)
        %             leadingEdgeProfiles(m,n)=nan;
        %         else
        y = segm;
        x = s1:s2;
        [pp1,~,Mu1] = polyfit(x,y,4);
        pp = pp1;
        pp(end)=pp(end)-threshold;
        R1 = roots(pp)*Mu1(2)+Mu1(1);
        R1 = R1(~abs(imag(R1)));
        if ~isempty(R1)
            [~,id] = min(abs(R1-(s1+s2)/2));
            R1 = R1(id);
            p = R1;
        else
            p = nan;
        end
        leadingEdgeProfiles(m,n) = p;
        % end
        
        s1b = max(TEn-b,1);
        s2b = min(TEn+b,size(Arc,2));
        segm = (Arc(m,s1b:s2b));
        %         p = find(segm>threshold,1,'last');
        %         if isempty(p)
        %             trailingEdgeProfiles(m,n)=nan;
        %         elseif (p == s2b-s1b+1)
        %             trailingEdgeProfiles(m,n)=nan;
        %         else
        y = segm;
        x = s1b:s2b;
        [pp2,~,Mu] = polyfit(x,y,4);
        pp = pp2;
        
        pp(end)=pp(end)-threshold;
        R2 = roots(pp)*Mu(2)+Mu(1);
        R2 = R2(~abs(imag(R2)));
        if ~isempty(R2)
        [~,id] = min(abs(R2-(s1b+s2b)/2));
        R2 = R2(id);
        p = R2;
        else
            p = nan;
        end
        trailingEdgeProfiles(m,n) = p;
        
        %end
%                         plot(s1:s2b,Arc(m,s1:s2b),s1:s2,Arc(m,s1:s2),'r',...
%                             s1b:s2b,Arc(m,s1b:s2b),'r',...
%                             s1:s2,polyval(pp1,s1:s2,[],Mu1),'g',...
%                             s1b:s2b,polyval(pp2,s1b:s2b,[],Mu),'g',...
%                             R1,polyval(pp1,R1,[],Mu1),'or',...
%                             R2,polyval(pp2,R2,[],Mu),'or')
%                         waitforbuttonpress
    end
end
end