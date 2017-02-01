function [ out ] = getAssessmentFields(assessment)
% function [ out ] = getAssessmentFields(assessment)
% Returns a function with the assessment fields parsed.
%
% Inputs
% assessment - an assessment structure (from getAssessment)
%
% Outputs
% out - a structure with parsed fields from assessment structure.
%
% See also
% getAssessment
% 
% P. Silveira, Sep. 2015
% BSX Proprietary

%out = assessment;   % by default, get all fields
 out.assessment = assessment.alpha__id;
% out.user_id = assessment.user_id;
% out.sport = assessment.sport;
% out.status = assessment.status;

if  ~isfield(assessment, 'lthr') || isempty(assessment.lthr)
    out.lthr = NaN;
else
    out.lthr = assessment.lthr;
end
if ~isfield(assessment, 'lt1hr') || isempty(assessment.lt1hr)
    out.lt1hr = NaN;
else
    out.lt1hr = assessment.lt1hr;
end
if ~isfield(assessment, 'stage_at_lt') || isempty(assessment.stage_at_lt)
    out.stage_at_lt = NaN;
else
    out.stage_at_lt = assessment.stage_at_lt;
end
if ~isfield(assessment, 'stage_at_lt_value') || isempty(assessment.stage_at_lt_value)
    out.stage_at_lt_value = NaN;
else
    out.stage_at_lt_value = assessment.stage_at_lt_value;
end
if ~isfield(assessment, 'calculated_lt_speed') || isempty(assessment.calculated_lt_speed)
    out.calculated_lt_speed = NaN;
else
    out.calculated_lt_speed = assessment.calculated_lt_speed;
end
if ~isfield(assessment, 'calculated_lt1_speed') || isempty(assessment.calculated_lt1_speed)
    out.calculated_lt1_speed = NaN;
else
    out.calculated_lt1_speed = assessment.calculated_lt1_speed;
end
if ~isfield(assessment, 'calculated_lt_power') || isempty(assessment.calculated_lt_power)
    out.calculated_lt_power = NaN;
else
    out.calculated_lt_power = assessment.calculated_lt_power;
end
if ~isfield(assessment, 'calculated_lt1_power') || isempty(assessment.calculated_lt1_power)
    out.calculated_lt1_power = NaN;
else
    out.calculated_lt1_power = assessment.calculated_lt1_power;
end
%%
if isfield(assessment, 'training_zones')
    if isfield(assessment.training_zones, 'exertion') && ~isempty(assessment.training_zones.exertion)
        out.LT2predLT1 = assessment.training_zones.exertion{2}.max;  % End of zone 2 (Aerobic threshold, as predicted by LT2)
    elseif isfield(assessment.training_zones, 'hr') && ~isempty(assessment.training_zones.hr)
        out.LT2predLT1 = assessment.training_zones.hr{2}.max;  % End of zone 2 (Aerobic threshold, as predicted by LT2)
    else
        out.LT2predLT1 = NaN;
    end
else
    out.LT2predLT1 = NaN;
end

end
