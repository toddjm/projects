[OD15, OD27] = processCounts(sweep, AllCnt, lookup_current, PP_THR, AMB_THR);
ODDiff = OD27-OD15; % differential OD
[ rawSmO2, R, mu_eff, HbF, Pk, mu_s, mu_a ] = calc_SmO2(ODDiff);
%mu_s = calc_mu_s(cent_wavel, BODY_PART); % if second argument is not set, calc_mu_s assumes we are monitoring a calf
%mu_a = calc_mu_a(mu_eff,repmat(mu_s, numel(sweep.time),1));  % absorption coefficient (1/mm)

% Re-calculate Hb concentrations
process.cHb15 = OD15 * invC15';
process.cHb27 = OD27 * invC27';

% Spatially-resolved projection calculations
pHhb = Pk(:,1);
pHbO2 = Pk(:,2);
pH2O = Pk(:,3);
% if exist('MELANIN', 'var')
%     pmelanin = projections(:,4);
% end

% Total Hemoglobin calculations
sweep.tHb_15 = sweep.cHbO2_15mm + sweep.cHhb_15mm;   % from device-calculated concentrations
sweep.tHb_27 = sweep.cHbO2_27mm + sweep.cHhb_27mm;
process.tHb_15 = sum(process.cHb15,2);   % from re-calculated concentrations
process.tHb_27 = sum(process.cHb27,2);
HbConc = 5e4*HbF./pH2O; % hemoglobin concentration

% SmO2 calculations
process.SmO2_15 = 100*process.cHb15(:,2) ./ process.tHb_15;   % using re-calculated concentrations
process.SmO2_27 = 100*process.cHb27(:,2) ./ process.tHb_27;
sweep.SmO2_15 = 100*sweep.cHbO2_15mm ./ sweep.tHb_15;   % using device-calculated concentrations
sweep.SmO2_27 = 100*sweep.cHbO2_27mm ./ sweep.tHb_27;
