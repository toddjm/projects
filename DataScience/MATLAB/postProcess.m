process.SmO2 = processSmO2(rawSmO2, MAP_METHOD, GAIN, FILTER_LENGTH*sweep.samp_rate, DIGITS);   % post-process
process.SmO2 = process.SmO2(1:sweep.samp_rate / UPDATE_RATE:end);    % simple (but not exact) decimation
if isfield(sweep, 'SmO2')
temp = sweep.SmO2;  % also process SmO2 value calculated by firmware
temp(temp > 100) = NaN;  % replace 0x3FF and 0x3FE values with NaN
sweep.SmO2 = temp;
end
dec_time = linspace(sweep.time(1), sweep.time(end), length(process.SmO2));    % decimated time
process.HbF = avgfiltNaN(HbF, TISSUE_FILTER_LENGTH*sweep.samp_rate);   % LPF total hemoglobin
process.pH2O = avgfiltNaN(pH2O, TISSUE_FILTER_LENGTH*sweep.samp_rate);
process.HbConc = avgfiltNaN(HbConc, TISSUE_FILTER_LENGTH*sweep.samp_rate);
[process.tissueTF, process.tissue] = istissue(HbF,HbConc);     % optical tissue detection

% Calculate min, max, averages and baselines
%process.stat.SmO2 = baselineStats(sweep.SmO2, BASELINE_RANGE*sweep.samp_rate);
process.stat.SmO2 = baselineStats(process.SmO2, BASELINE_RANGE*sweep.samp_rate); % use this until device-calculated SmO2 gets corrected
process.stat.HR = baselineStats(sweep.HR, BASELINE_RANGE*sweep.samp_rate);
process.stat.pH2O = baselineStats(process.pH2O, BASELINE_RANGE*sweep.samp_rate);
process.stat.HbConc = baselineStats(process.HbConc, BASELINE_RANGE*sweep.samp_rate);
process.stat.HbF = baselineStats(process.HbF, BASELINE_RANGE*sweep.samp_rate);
