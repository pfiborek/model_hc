function [elementNodes_pl,nodeCoordinates_pl]=...
    internal_Nodes_SEM(structure_act,num_el,case_name)   
%structure_act=structure(1);
elementNodes_pl=structure_act.elementNodes;
numberElements_pl=size(elementNodes_pl,1);
nodeCoordinates_pl=structure_act.nodeCoordinates;
ksi=structure_act.ksi;
n=structure_act.DOF(2);
element_print=1:numberElements_pl;

if n<2
    msgbox('You need at least 2 nodes on edge of element', 'Error','error');
    return
elseif n>10
    msgbox('Maximum no of nodes on edge of element is 10', 'Error','error');
    return
end


%
%
%   3    10   9    4
%   O----O----O----O   
%   |    |    |    |
% 11O--15O----O16--O8
%   |    |    |    | 
% 12O--13O----O14--O7
%   |    |    |    |
%   O----O----O----O
%   1    5    6    2
%
%

n_int=n-2;
max_Node=max(max(elementNodes_pl));
ksi_int=ksi(2:n-1);
nodeCoordinates_temp=zeros(numberElements_pl*n_int*4,3);
nodes_order=[1,2,3,4,1];
for i=1:numberElements_pl;
n_en=elementNodes_pl(i,:);
for j=1:4 % because 4 edges of element
    for k=1:3
    nodeCoordinates_temp(1+(j-1)*n_int+4*n_int*(i-1):n_int*(j+4*(i-1)),k)=...
    (nodeCoordinates_pl(n_en(nodes_order(j+1)),k)+...
    nodeCoordinates_pl(n_en(nodes_order(j)),k)+...
    (nodeCoordinates_pl(n_en(nodes_order(j+1)),k)-...
    nodeCoordinates_pl(n_en(nodes_order(j)),k))*ksi_int')/2;
    end
end
end

[~,m1,~]=unique(nodeCoordinates_temp,'first','rows');
nodeCoordinates_int_edge=nodeCoordinates_temp(sort(m1),:);
if n>=3
    elementNodes_pl_int_edge=zeros(numberElements_pl,4*n_int);
    c1=ceil(numberElements_pl/100);
    proc_name=[case_name,'Internal Nodes_',num2str(num_el)];
    tic
    %time_0=clock;

for i=1:numberElements_pl;
  
%  [c1]=proc_time(i,c1,numberElements_pl,proc_name);

  for j=1:4 % number of edges
      for k=1:n_int % number nodes per edge
    elementNodes_pl_int_edge(i,k+(j-1)*n_int)=...
    find(all(abs(repmat(nodeCoordinates_temp(k+(j-1)*...
    n_int+4*n_int*(i-1),:),size(nodeCoordinates_int_edge,1),1)-...
    nodeCoordinates_int_edge)<1e-10,2));
      end
  end
end
toc

clc
elementNodes_pl_int_int=(1:(numberElements_pl*n_int.^2))+...
    max(max(elementNodes_pl_int_edge));
elementNodes_pl_int_int=reshape(elementNodes_pl_int_int,n_int.^2,...
    numberElements_pl);
elementNodes_pl_int_int=elementNodes_pl_int_int';
nodeCoordinates_int_int=zeros(numberElements_pl*n_int^2,3);


for i=1:numberElements_pl;
n_el=elementNodes_pl_int_edge(i,:);


n_el1=n_el(1+0*n_int:1*n_int);
n_el2=n_el(1+1*n_int:2*n_int);
n_el3=n_el(3*n_int:-1:1+2*n_int);
n_el4=n_el(4*n_int:-1:1+3*n_int);
    A13=nodeCoordinates_int_edge(n_el3,2)-nodeCoordinates_int_edge(n_el1,2);
    B13=nodeCoordinates_int_edge(n_el1,1)-nodeCoordinates_int_edge(n_el3,1);
    C13=(nodeCoordinates_int_edge(n_el1,2)-nodeCoordinates_int_edge(n_el3,2)).*...
        nodeCoordinates_int_edge(n_el1,1)+...
        (nodeCoordinates_int_edge(n_el3,1)-nodeCoordinates_int_edge(n_el1,1)).*...
        nodeCoordinates_int_edge(n_el1,2);
    A42=nodeCoordinates_int_edge(n_el2,2)-nodeCoordinates_int_edge(n_el4,2);
    B42=nodeCoordinates_int_edge(n_el4,1)-nodeCoordinates_int_edge(n_el2,1);
    C42=(nodeCoordinates_int_edge(n_el4,2)-nodeCoordinates_int_edge(n_el2,2)).*...
        nodeCoordinates_int_edge(n_el4,1)+...
        (nodeCoordinates_int_edge(n_el2,1)-nodeCoordinates_int_edge(n_el4,1)).*...
        nodeCoordinates_int_edge(n_el4,2);
    W=A13*B42'-B13*A42';
    Wx=B13*C42'-C13*B42';
    Wy=C13*A42'-A13*C42';
    X_int=reshape(Wx./W,[],1);
    Y_int=reshape(Wy./W,[],1);
    Z_int=ones(length(X_int),1).*nodeCoordinates_int_edge(i,3);
    nodeCoordinates_int_int(1+n_int.^2*(i-1):n_int.^2*i,:)=[X_int,Y_int,Z_int];
end
elementNodes_int=[elementNodes_pl_int_edge,elementNodes_pl_int_int]+max_Node;
nodeCoordinates_int=[nodeCoordinates_int_edge;nodeCoordinates_int_int];
elementNodes_pl=[elementNodes_pl,elementNodes_int];
nodeCoordinates_pl=[nodeCoordinates_pl;nodeCoordinates_int];


    elementNodes_pl3=zeros(size(elementNodes_pl));
    for ii=1:n
        if ii==1
        elementNodes_pl3(:,1+n*(ii-1):n*ii)=elementNodes_pl(:,[1,4+1:4+n_int,2]);
        elseif ii>1&&ii<n
        elementNodes_pl3(:,1+n*(ii-1):n*ii)=elementNodes_pl(:,[4+4*n_int-ii+2,...
            (ii-2)*n_int+1+4+4*n_int:(ii-2)*n_int+4+4*n_int+n_int,...
            ii-1+4+1*n_int]);
        elseif ii==n
        elementNodes_pl3(:,1+n*(ii-1):n*ii)=elementNodes_pl(:,[4,...
            4+3*n_int:-1:4+2*n_int+1,3]);
        end
    end
    elementNodes_pl=elementNodes_pl3;

end

plot_nodes='no';
if strcmpi(plot_nodes,'yes')==1
    
for i=element_print
    e=elementNodes_pl(i,:);
    for j=1:length(e)
    str=num2str(e(j));
    x=nodeCoordinates_pl(e(j),1);
    y=nodeCoordinates_pl(e(j),2);
    z=nodeCoordinates_pl(e(j),3);
    text(x,y,z,str)
    end
    
end
end

plot_nodes='no';
if strcmpi(plot_nodes,'yes')==1
    
    for i=element_print
    e=elementNodes_pl(i,:);
    str=num2str(i);
    x=1.05*nodeCoordinates_pl(e(ceil(n*ceil(n/2-1)+n/2)),1);
    y=nodeCoordinates_pl(e(ceil(n*ceil(n/2-1)+n/2)),2);
    z=nodeCoordinates_pl(e(ceil(n*ceil(n/2-1)+n/2)),3);
    text(x,y,z,str)
    end
    
end
end

