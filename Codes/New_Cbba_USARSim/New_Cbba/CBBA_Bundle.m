
% Main CBBA bundle building/updating (runs on each individual agent)
%---------------------------------------------------------------------%

function [CBBA_Data newBid] = CBBA_Bundle(CBBA_Params, CBBA_Data, agent, tasks)

% Update bundles after messaging to drop tasks that are outbid
CBBA_Data = CBBA_BundleRemove(CBBA_Params, CBBA_Data);

% Bid on new tasks and add them to the bundle
[CBBA_Data, newBid] = CBBA_BundleAdd(CBBA_Params, CBBA_Data, agent, tasks);

return
