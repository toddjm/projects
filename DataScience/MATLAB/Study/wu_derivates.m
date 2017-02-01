N = 6;                 % Order of polynomial fit
F = sweep_Calf.samp_rate*20+1;                % Window length
[b,g] = sgolay(N,F);   % Calculate S-G coefficients
HalfWin  = ((F+1)/2) -1;
dx = 1/sweep_Calf.samp_rate;

for n = (F+1)/2:length(sweep_Calf.time)-(F+1)/2,
  % Zeroth derivative (smoothing only)
  SG0(n) = dot(g(:,1),sweep_Calf.SmO2(n - HalfWin:n + HalfWin));

  % 1st differential
  SG1(n) = dot(g(:,2),sweep_Calf.SmO2(n - HalfWin:n + HalfWin));

  % 2nd differential
  SG2(n) = 2*dot(g(:,3)',sweep_Calf.SmO2(n - HalfWin:n + HalfWin))';
end

SG0 = SG0';
SG1 = SG1/dx;         % Turn differential into derivative
SG2 = SG2/(dx*dx);    % and into 2nd derivative

% Trim the non-protocol segment
trimEnd = sweep_Calf.samp_rate*30;
trimStart = find(sweep_Calf.time>=0,1);

subplot(3,1,1)
plot(sweep_Calf.time(trimStart+HalfWin/2:end-trimEnd-HalfWin/2-1), SG0(trimStart:end-trimEnd));
ylabel('Smoothed Data')

subplot(3,1,2)
plot(sweep_Calf.time(trimStart+HalfWin/2:end-trimEnd-HalfWin/2-1), SG1(trimStart:end-trimEnd));
ylabel('1st derivative')

subplot(3,1,3)
plot(sweep_Calf.time(trimStart+HalfWin/2:end-trimEnd-HalfWin/2-1), SG2(trimStart:end-trimEnd));
ylabel('2nd derivative')