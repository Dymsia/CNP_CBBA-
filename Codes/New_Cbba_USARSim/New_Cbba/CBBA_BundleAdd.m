
% Create bundles for each agent
%---------------------------------------------------------------------%

function [CBBA_Data, newBid] = CBBA_BundleAdd(CBBA_Params, CBBA_Data, agent, tasks)

epsilon = 10e-6;
newBid  = 0;

% Check if bundle is full
bundleFull = isempty(find(CBBA_Data.bundle == -1));

% Initialize feasibility matrix (to keep track of which j locations can be pruned)
feasibility = ones(CBBA_Params.M, CBBA_Params.MAX_DEPTH+1); 

while(bundleFull == 0)

    % Update task values based on current assignment
    [CBBA_Data bestIdxs taskTimes feasibility] = CBBA_ComputeBids(CBBA_Params, CBBA_Data, agent, tasks, feasibility);

    % Determine which assignments are available
      
    D1 = (CBBA_Data.bids - CBBA_Data.winnerBids > epsilon);
    D2 = (abs(CBBA_Data.bids - CBBA_Data.winnerBids) <= epsilon);
    D3 = (CBBA_Data.agentIndex < CBBA_Data.winners);       % Tie-break based on agent index

    D = D1 | (D2 & D3);

    % Select the assignment that will improve the score the most and
    % place bid
    [value bestTask] = max(D.*CBBA_Data.bids);

    if( value > 0 )

        % Set new bid flag
        newBid = 1;
        
        % Check for tie
        allvalues = find(D.*CBBA_Data.bids == value);
        if(length(allvalues) == 1),
            bestTask = allvalues;
        else
            % Tie-break by which task starts first
            earliest = realmax;
            for i=1:length(allvalues),
                if ( tasks(allvalues(i)).start < earliest),
                    earliest = tasks(allvalues(i)).start;
                    bestTask = allvalues(i);
                end
            end
        end

        CBBA_Data.winners(bestTask)    = CBBA_Data.agentIndex;
        CBBA_Data.winnerBids(bestTask) = CBBA_Data.bids(bestTask);

        CBBA_Data.path          = CBBA_InsertInList(CBBA_Data.path, bestTask, bestIdxs(1,bestTask));
        CBBA_Data.times         = CBBA_InsertInList(CBBA_Data.times, taskTimes(1,bestTask), bestIdxs(1,bestTask));
        CBBA_Data.scores        = CBBA_InsertInList(CBBA_Data.scores, CBBA_Data.bids(bestTask), bestIdxs(1,bestTask));
        len                     = length(find(CBBA_Data.bundle > -1));
        CBBA_Data.bundle(len+1) = bestTask;
        
        
        % Update feasibility

        for i = 1:CBBA_Params.M
            feasibility(i,:) = CBBA_InsertInList(feasibility(i,:), feasibility(i,bestIdxs(1,bestTask)), bestIdxs(1,bestTask));
        end

    else
        % disp('Value is zero, breaking');
        break;
    end

    % Check if bundle is full
    bundleFull = isempty(find(CBBA_Data.bundle == -1));
end


return