trials = 17; % number of trials
blocks = 9; % number of blocks
instructions = 2; % seconds
breaks = 1; % seconds

run_dur = compute_duration(trials, blocks, instructions, breaks)

function run_duration = compute_duration(trials, blocks, instructions, breaks)

stim_time = 5.55*trials*blocks;
wait_time = instructions*2*blocks + breaks*(blocks-1);

run_duration = seconds(stim_time + wait_time);
run_duration.Format = 'mm:ss.SSS';
end