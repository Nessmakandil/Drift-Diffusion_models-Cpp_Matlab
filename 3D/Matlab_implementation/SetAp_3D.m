% Setup of 3D hole continuity matrix using loop and spdiag

function Ap = SetAp_3D(p_mob_avged, Bernoulli_p_values)

global num_elements N

%extract variables from struct, for brevity in eqns
Bp_posX = Bernoulli_p_values.Bp_posX;
Bp_negX = Bernoulli_p_values.Bp_negX;
Bp_posY = Bernoulli_p_values.Bp_posY;
Bp_negY = Bernoulli_p_values.Bp_negY;
Bp_posZ = Bernoulli_p_values.Bp_posZ;
Bp_negZ = Bernoulli_p_values.Bp_negZ;

p_mob_X_avg = p_mob_avged.p_mob_X_avg;
p_mob_Y_avg = p_mob_avged.p_mob_Y_avg;
p_mob_Z_avg = p_mob_avged.p_mob_Z_avg;


Ap_val = zeros(num_elements, 7);   %this is a matrix which will just store the non-zero diagonals of 2D hole continuity eqn

%NOTE: index is not neccesarily equal to i (the x index of V), it is the
%index of the diagonal arrays.
%--------------------------------------------------------------------------
%Lowest diagonal: 
values = -p_mob_Z_avg.*Bp_posZ;
values_cut = zeros(N, N, N);
values_cut(1:N,1:N,1:N-1) = values(2:N+1,2:N+1,2+1:N+1);  %shift by +1,   %note: the k values  uses 2+1:N+1 -->  b/c k = 2:N is what is needed..., so need to skip k = 1, which corresponds to 2 in orig values matrix
Ap_val(1:N^3, 1) = values_cut(:);  %reshapes into a vector and fills the Ap_val diagonal
%THIS FILLING METHOD IS 5x faster than using for loop!

% index = 1;
% for k = 2:N
%     for j = 1:N
%         for i = 1:N
%             Ap_val(index,1) = values(i+1,j+1,k+1);
%             index = index +1;
%         end 
%     end
% end
%--------------------------------------------------------------------------
%lower diagonal
values = -p_mob_Y_avg.*Bp_posY;
values_cut = zeros(N, N, N);          %RESET THE SIZE OF VALUES_CUT: this is
                                      %important!!
                                      
  %note: made the j of N size-->  so when leave the last Nth elements,
  %unfilled--> this corresponds to the 0's subblocks

values_cut(1:N,1:N-1,1:N) = values(2:N+1,2+1:N+1,2:N+1);  
Ap_val(1:N^3, 2) = values_cut(:);  %is N^3 lenght, but the last block will just have 0's....


% index = 1;
% for k = 1:N
%     for j = 2:N
%         for i = 1:N
%             Ap_val(index,2) = values(i+1,j+1,k+1);
%             index = index+1;
%         end
%     end
%     index = index + N;  %add on the 0's subblock
% end

%--------------------------------------------------------------------------
%main lower diagonal (below main diagonal)
values = -p_mob_X_avg.*Bp_posX;
values_cut = zeros(N, N, N); %again made i have N elements here, but fill to N-1--> to have the  0's in corners where need them
values_cut(1:N-1,1:N,1:N) = values(2+1:N+1,2:N+1,2:N+1); 
Ap_val(1:N^3, 3) = values_cut(:);
% index = 1;
% for k = 1:N
%     for j = 1:N
%         for i = 2:N
%             Ap_val(index,3) = values(i+1,j+1,k+1);
%             index = index+1;
%         end
%         index = index +1;  %add on the corner element which is 0
%     end
% end
%--------------------------------------------------------------------------
%main diagonal
values1 = p_mob_Z_avg.*Bp_negZ + p_mob_Y_avg.*Bp_negY + p_mob_X_avg.*Bp_negX;
values2 = p_mob_X_avg.*Bp_posX;  %these have +1+1 in some elements, so need to be seperate
values3 = p_mob_Y_avg.*Bp_posY;
values4 = p_mob_Z_avg.*Bp_posZ;

% values_cut = zeros(N,N,N);  %preallocation is not neccessary  here, since
% all the values are filled
values_cut(1:N,1:N,1:N) = values1(2:N+1, 2:N+1,2:N+1) + values2(2+1:N+1+1, 2:N+1,2:N+1) + values3(2:N+1,2+1:N+1+1,2:N+1) + values4(2:N+1,2:N+1,2+1:N+1+1);
Ap_val(1:N^3,4) = values_cut(:);

% index = 1;
% for k = 1:N
%     for j = 1:N
%         for i = 1:N     
%             Ap_val(index,4) = values1(i+1,j+1,k+1) + values2(i+1+1,j+1,k+1) + values3(i+1,j+1+1,k+1) + values4(i+1,j+1,k+1+1);
%             index = index+1;
%         end
%     end
% end

%--------------------------------------------------------------------------
%main uppper diagonal
values = -p_mob_X_avg.*Bp_negX;
values_cut = zeros(N,N,N);
values_cut(1:N-1, 1:N,1:N) = values(2:N, 2:N+1, 2:N+1);

Ap_val(2:N^3+1,5) = values_cut(:);
% index = 2;
% for k = 1:N
%     for j = 1:N
%         for i = 1:N-1     
%             Ap_val(index,5) = values(i+1+1,j+1,k+1);
%             index = index+1;
%         end
%         index = index+1;  %add on the element which = 0 --> corner...
%     end
% end

%--------------------------------------------------------------------------
%upper diagonal
values = -p_mob_Y_avg.*Bp_negY;
values_cut = zeros(N,N,N);
values_cut(1:N, 1:N-1,1:N) = values(2:N+1, 2:N, 2:N+1);

Ap_val(1+N:N^3+N, 6) = values_cut(:);
% 
% index = 1+N;
% for k = 1:N
%     for j = 1:N-1
%         for i = 1:N    
%             Ap_val(index, 6) = values(i+1,j+1+1,k+1);
%             index = index+1;
%         end
%     end
%     index = index + N;  %add on the empty block--> of 0's corresponding to y BC's. 
% end
%--------------------------------------------------------------------------
%far upper diagonal
values = -p_mob_Z_avg.*Bp_negZ;
values_cut = zeros(N,N,N);
values_cut(1:N, 1:N,1:N-1) = values(2:N+1, 2:N+1, 2:N);

Ap_val(1+N*N:N^3+N^2,7) = values_cut(:);

% index = 1+N*N;
% for k = 1:N-1
%     for j = 1:N
%         for i = 1:N    
%              Ap_val(index,7) = values(i+1,j+1,k+1+1);  
%              index = index+1;
%         end
%     end
% end
%all not specified elements will remain zero, as they were initialized
%above.

Ap = spdiags(Ap_val, [-N^2 -N -1 0 1 N N^2], num_elements, num_elements); %A = spdiags(B,d,m,n) creates an m-by-n sparse matrix by taking the columns of B and placing them along the diagonals specified by d.

%Ap_matrix = full(Ap); %use to see the full matrix

