% Get all assessments with status of ERROR
ErrorList = getAssessmentList('status','ERROR');
j=0;
for i=1:length(ErrorList)
    % Pull each assessment. 
    test = getAssessment(ErrorList{i,1});
    
    % Verify that the error field exists. Some Error status dont have this
    % field, This seems ot be a bug on the server
    if isfield(test,'error')
        % Check for specific type of error: unhandled
        if ~isempty( regexpi(test.error.description, 'exception'))
            j = j+1;
            badidx(j) = i;
            
            %Build a List of assessment IDs and Error descriptions
            UnhandledErrorList{j,1} = ErrorList{i};
            UnhandledErrorList{j,2} = test.error.description;
            
            % Pull th eoxy an dopticla files
            urlwrite(test.links.oxy,strcat(test.alpha__id,'.oxy'))
            if isfield(test.links,'optical')
                urlwrite(test.links.optical,strcat(test.alpha__id,'.bin'))
            end
            
        end
    end
end
