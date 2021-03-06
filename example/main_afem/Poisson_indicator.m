function eta = Poisson_indicator(node,elem,u,pde)

% ----------------- aux ------------
aux = auxgeometry(node,elem);
area = aux.area; diameter = aux.diameter;
auxT = auxstructure(node,elem);
elem2edge = auxT.elem2edge; edge = auxT.edge; edge2elem = auxT.edge2elem;

% ------------------ elemRes ---------------
f = pde.f;
n = 3;  [lambda,weight] = quadpts(n);
NT = size(elem,1);  elemRes = zeros(NT,1);
for iel = 1:NT
    vK = node(elem(iel,:),:); % vertices of K
    xy = lambda*vK;
    elemRes(iel) = dot(weight,f(xy).^2);
end
elemRes = diameter.^2.*area.*elemRes;


% ---------------------- elemJump -----------------------
% edge vectors 
ve = node(edge(:,2),:)-node(edge(:,1),:);
% scaled norm vectors he*ne
nedge = [-ve(:,2),ve(:,1)]; % stored in rows

% information of left and right elements
k1 = edge2elem(:,1); k2 = edge2elem(:,2); 
index1 = elem(k1,:);  index2 = elem(k2,:);
zL1 = node(index1(:,1),:);   zR1 = node(index2(:,1),:);
zL2 = node(index1(:,2),:);   zR2 = node(index2(:,2),:);
zL3 = node(index1(:,3),:);   zR3 = node(index2(:,3),:);

% grad of nodal basis functions
gradL1 = [zL2(:,2)-zL3(:,2), zL3(:,1)-zL2(:,1)]; % stored in rows
gradL2 = [zL3(:,2)-zL1(:,2), zL1(:,1)-zL3(:,1)];
gradR1 = [zR2(:,2)-zR3(:,2), zR3(:,1)-zR2(:,1)];
gradR2 = [zR3(:,2)-zR1(:,2), zR1(:,1)-zR3(:,1)];

gradL1 = gradL1./repmat(2*area(k1),1,2); gradR1 = gradR1./repmat(2*area(k2),1,2);
gradL2 = gradL2./repmat(2*area(k1),1,2); gradR2 = gradR2./repmat(2*area(k2),1,2);
gradL3 = -(gradL1+gradL2);    gradR3 = -(gradR1+gradR2);

% grad of uh 
gradLu = repmat(u(index1(:,1)),1,2).*gradL1 ...
       + repmat(u(index1(:,2)),1,2).*gradL2 ...
       + repmat(u(index1(:,3)),1,2).*gradL3;
gradRu = repmat(u(index2(:,1)),1,2).*gradR1 ...
       + repmat(u(index2(:,2)),1,2).*gradR2 ...
       + repmat(u(index2(:,3)),1,2).*gradR3;

% jump of gradu
Jumpu = gradLu-gradRu;
Jumpu(k1==k2,:) = gradLu(k1==k2,:);

% edgeJump
edgeJump = dot(Jumpu',nedge').^2; edgeJump = edgeJump';

% elemJump
elemJump = sum(edgeJump(elem2edge),2);

% --------- Local error indicator ------------
eta = (elemRes + elemJump).^(1/2);