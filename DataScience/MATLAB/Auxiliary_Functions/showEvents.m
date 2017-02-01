function showEvents( events, times, plateau)
% function showEvents( events, times, plateau)
% Shows a line in the current plot separating the events defined by cell
% array events at times defined by array times. 
%
% Inputs
% events - cell array with strings with event names
% times - numeric array with time (in the same units used in the current
% plot) when events take place
% plateau - (optional). If defined, showEvents also draws arrows at times
% connecting one plateau value to the next. Useful to show transitions
% between events. May be a single row vector (1xn) or a two-row vector (2xn), indicating two sets of plateaus at each event. In that case, each row is plotted as arrows of different colors. 
%
% P. Silveira, Dec. 2015
% BSX Proprietary

TXT_COLOR = [0 1 1]; % text color. [0 1 1 ] = cyan
LINE_WIDTH = 1; % width of vertical line separating events
LINE_COLOR = [0 1 0];   % line color. [0 1 0] = Green
ARROW_COLOR{1} = [0.7 0 0];  % arrow color for first row of plateaus.
ARROW_COLOR{2} = [0.5 0.5 0.5];

ax = axis;
times = double(times);  % convert from single to double
for ii = 1:numel(events)
%     if isempty(events(ii))  % skip empty labels
%         continue
%     end
    line([times(ii) times(ii)],[ax(3) ax(4)],'Color', LINE_COLOR, 'LineStyle', '--', 'LineWidth',  LINE_WIDTH)
    text(times(ii),(ax(3)+ax(4))/2, events(ii), 'Rotation', 90, 'Color', TXT_COLOR)
end

if exist('plateau', 'var')
    sz = size(plateau);
    for jj = 1:sz(1)
        for ii = 1:numel(times)-2
            %        annotation('arrow',[times(ii+1) times(ii+1)]./ax(2), [plateau(ii) plateau(ii+1)]./ax(4), 'Color', ARROW_COLOR)
            if plateau(jj,ii+1) > plateau(jj,ii)
                line([times(ii+1) times(ii+1)], [plateau(jj,ii) plateau(jj,ii+1)], 'Color', ARROW_COLOR{jj}, 'Marker', '^')
            elseif plateau(jj,ii+1) < plateau(jj,ii)
                line([times(ii+1) times(ii+1)], [plateau(jj,ii) plateau(jj,ii+1)], 'Color', ARROW_COLOR{jj}, 'Marker', 'V')
            end
        end
    end
end
    
end

