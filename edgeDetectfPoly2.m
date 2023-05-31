function [leadingEdgeProfiles,trailingEdgeProfiles] = edgeDetectfPoly2(leadingEdges,trailingEdges,Arc,b,threshold)
%polynomial fitting

leadingEdgeProfiles = zeros(size(Arc,1),length(leadingEdges));
trailingEdgeProfiles = zeros(size(Arc,1),length(trailingEdges));
for n = 1:length(leadingEdges)
    LEn = leadingEdges(n);
    TEn = trailingEdges(n);
    for m = 1:size(Arc,1)
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
        xint = s1:1:s2;
        [pp1,~,mu1] = polyfit(x,y,4);
        [mli,vi] = max(polyval(pp1,xint,[],mu1));

        %leadingEdgeProfiles(m,n) = -pp1(2)/(2*pp1(1));
        leadingEdgeProfiles(m,n) = xint(vi);
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
        xint = s1b:1:s2b;
        [pp2,~,mu2] = polyfit(x,y,4);

        %trailingEdgeProfiles(m,n) = -pp2(2)/(2*pp2(1));
        [mti,vi] = max(polyval(pp2,xint,[],mu2));
        trailingEdgeProfiles(m,n) = xint(vi);

        %end
%         plot(s1:s2b,Arc(m,s1:s2b),s1:s2,Arc(m,s1:s2),'r',...
%             s1b:s2b,Arc(m,s1b:s2b),'r',...
%             s1:s2,polyval(pp1,s1:s2,[],mu1),'g',...
%             s1b:s2b,polyval(pp2,s1b:s2b,[],mu2),'g',...
%             trailingEdgeProfiles(m,n),mti,'ok',leadingEdgeProfiles(m,n),mli,'ok')
%         waitforbuttonpress
    end
end