function y = relu(x)
%RELU Compute ReLU on input
%   Returns rectified linear unit output on the input x as defined:
%   relu(x) = x if x > 0
%             0 if x <= 0
y = x;
y(y < 0) = 0;
end

