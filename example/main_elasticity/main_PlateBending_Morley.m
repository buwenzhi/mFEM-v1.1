clc;clear;close all
% -------- Mesh and boudary conditions --------
a1 = 0; b1 = 1; a2 = 0; b2 = 1;
Nx = 20; Ny = 20; h1 = (b1-a1)/Nx; h2 = (b2-a2)/Ny;
[node,elem] = squaremesh([a1 b1 a2 b2],h1,h2);
bdStruct = setboundary(node,elem);

% ------------ PDE data ------------
pde = PlateBendingData;

% ----------- Plate bending Morley element --------
w = PlateBendingMorley(node,elem,pde,bdStruct); % sign basis functions
%w = PlateBendingMorley1(node,elem,pde,bdStruct); % sign edge

% --------- error analysis -------
uexact = pde.uexact;  we = uexact(node);
figure,
subplot(1,2,1), showsolution(node,elem,w);
zlabel('w');
subplot(1,2,2), showsolution(node,elem,we);
zlabel('we');
Eabs = w-we;  % Absolute errors
figure,showsolution(node,elem,Eabs); zlim('auto');

format shorte
Err = norm(Eabs)./norm(we)
zlabel('Err');


