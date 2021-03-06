% Setup of 2D hole continuity matrix using loop and spdiag

function Ap = SetAp_2D(p_mob_avged, Bernoulli_p_values)

global num_elements N

%extract variables from struct, for brevity in eqns
Bp_posX = Bernoulli_p_values.Bp_posX;
Bp_negX = Bernoulli_p_values.Bp_negX;
Bp_posZ = Bernoulli_p_values.Bp_posZ;
Bp_negZ = Bernoulli_p_values.Bp_negZ;

p_mob_X_avg = p_mob_avged.p_mob_X_avg;
p_mob_Z_avg = p_mob_avged.p_mob_Z_avg;

Ap_val = zeros(num_elements, 5);   %this is a matrix which will just store the non-zero diagonals of 2D hole continuity eqn

%--------------------------------------------------------------------------
%Lowest diagonal: 
values = -p_mob_Z_avg.*Bp_posZ;
values_cut = zeros(N, N);
values_cut(1:N,1:N-1) = values(2:N+1,2+1:N+1);  %shift by +1,   %note: the k values  uses 2+1:N+1 -->  b/c k = 2:N is what is needed..., so need to skip k = 1, which corresponds to 2 in orig values matrix
Ap_val(1:N^2, 1) = values_cut(:);  %reshapes into a vector and fills the Ap_val diagonal


% i = 1;
% j = 2;
% for index = 1:N*(N-1)      %(1st element corresponds to Nth row  (number of elements = N*(N-1)
%     Ap_val(index,1) = -((p_mob(i+1,j+1) + p_mob(i+1+1,j+1))/2.)*Bp_posZ(i+1,j+1);
%     
%     i = i+1;
%     if (i > N)
%         i = 1;  %reset i when reach end of subblock
%         j = j+1;   %increment j
%     end
% 
% end
%--------------------------------------------------------------------------
%main lower diagonal (below main diagonal): corresponds to V(i-1,j)
values = -p_mob_X_avg.*Bp_posX;
values_cut = zeros(N, N); %again made i have N elements here, but fill to N-1--> to have the  0's in corners where need them
values_cut(1:N-1,1:N) = values(2+1:N+1,2:N+1); 
Ap_val(1:N^2, 2) = values_cut(:);



% i = 2;
% j = 1;
% for index = 1:num_elements-1      %(1st element corresponds to 2nd row)%NOTE: this is tricky!-->some elements are 0 (at the corners of the
% %subblocks)
% %     if(i == 1)  %will correspond to the elements at subblock corners
% %         Ap_val(index,2) = 0;   
% %     else
%     if (i > 1)
%         Ap_val(index,2) = -((p_mob(i+1,j+1) + p_mob(i+1,j+1+1))/2.)*Bp_posX(i+1,j+1);
%     end
%     
%     i = i+1;
%     if (i > N)
%         i = 1;
%         j = j+1;
%     end
% end
%--------------------------------------------------------------------------
%main diagonal: corresponds to V(i,j)
values1 = p_mob_Z_avg.*Bp_negZ + p_mob_X_avg.*Bp_negX;
values2 = p_mob_X_avg.*Bp_posX;  %these have +1+1 in some elements, so need to be seperate
values3 = p_mob_Z_avg.*Bp_posZ;

values_cut = zeros(N,N);  %preallocation is not neccessary  here, since
% all the values are filled
values_cut(1:N,1:N) = values1(2:N+1, 2:N+1) + values2(2+1:N+1+1, 2:N+1) + values3(2:N+1,2+1:N+1+1);
Ap_val(1:N^2,3) = values_cut(:);


% i = 1;
% j = 1;
% for index =  1:num_elements       
%     Ap_val(index,3) = ((p_mob(i+1,j+1) + p_mob(i+1,j+1+1))/2.)*Bp_negX(i+1,j+1) + ((p_mob(i+1+1,j+1) + p_mob(i+1+1,j+1+1))/2.)*Bp_posX(i+1+1,j+1) + ((p_mob(i+1,j+1) + p_mob(i+1+1,j+1))/2.)*Bp_negZ(i+1,j+1) + ((p_mob(i+1,j+1+1) + p_mob(i+1+1,j+1+1))/2.)*Bp_posZ(i+1,j+1+1);
% 
%     i = i+1;
%     if (i > N)
%         i = 1;
%         j = j+1;
%     end
% 
% end
%--------------------------------------------------------------------------
%main uppper diagonal: corresponds to V(i+1,j)
values = -p_mob_X_avg.*Bp_negX;
values_cut = zeros(N,N);
values_cut(1:N-1, 1:N) = values(2+1:N+1, 2:N+1); %i+1+1

Ap_val(2:N^2+1,4) = values_cut(:);

% i = 1;
% j = 1;
% for index = 2:num_elements     %matlab fills this from the bottom (so i = 2 corresponds to 1st row in matrix)
%     
% %     if(i == 0)     
% %         Ap_val(index,4) = 0;
% %     else
%     if (i > 0)
%         Ap_val(index,4) = -((p_mob(i+1+1,j+1) + p_mob(i+1+1,j+1+1))/2.)*Bp_negX(i+1+1,j+1);
%     end
%     
%     i=i+1;
%     if (i > N-1)  %here are only N-1 elements per block and i starts from 1
%         i = 0;
%         j  = j+1;
%     end
%     
% end
%--------------------------------------------------------------------------
%far upper diagonal: corresponds to V(i,j+1)
values = -p_mob_Z_avg.*Bp_negZ;
values_cut = zeros(N,N);
values_cut(1:N, 1:N-1) = values(2:N+1, 2+1:N+1);  %2+1 b/c is j+1+1

Ap_val(1+N:N^2+N, 5) = values_cut(:);


% i = 1;
% j = 1;
% for index = 1+N:num_elements      %matlab fills from bottom, so this starts at 1+N (since 1st element is in the 2nd subblock of matrix) 
%     Ap_val(index,5) = -((p_mob(i+1,j+1+1) + p_mob(i+1+1,j+1+1))/2.)*Bp_negZ(i+1,j+1+1);            %1st element corresponds to 1st row.   this has N^2 -N elements
%     
%     i = i+1;
%     
%     if (i > N)
%         i = 1;
%         j = j+1;
%     end
% end
%--------------------------------------------------------------------------
%all not specified elements will remain zero, as they were initialized
%above.

Ap = spdiags(Ap_val, [-N -1 0 1 N], num_elements, num_elements); %A = spdiags(B,d,m,n) creates an m-by-n sparse matrix by taking the columns of B and placing them along the diagonals specified by d.
%diagonals  [-N -1 0 1 N].  -N and N b/c the far diagonals are in next
%subblocks, N diagonals away from main diag.


%Ap_matrix = full(Ap); %use to see the full matrix

