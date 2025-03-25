%% clear...
clear all global
close all

%% init o_ptb
init_o_ptb_paths();

%% get a configuration object
ptb_cfg = o_ptb.PTB_Config();

%% do the configuration
ptb_cfg.fullscreen = false;
ptb_cfg.window_scale = 0.2;
ptb_cfg.skip_sync_test = true;
ptb_cfg.hide_mouse = false;

%% init....
ptb = o_ptb.PTB.get_instance(ptb_cfg);
ptb.setup_screen();

%% draw shapes
filled_circle = o_ptb.stimuli.visual.FilledCircle(150, [255 0 0]);
filled_circle.move(-400, -250);
ptb.draw(filled_circle);

frame_circle = o_ptb.stimuli.visual.FrameCircle(122, [0 255 0], 10);
frame_circle.move(400, 250);
ptb.draw(frame_circle);

frame_oval = o_ptb.stimuli.visual.FrameOval(80, 120, [128 0 128], 20);
ptb.draw(frame_oval);

filled_oval_arc = o_ptb.stimuli.visual.FilledOvalArc(240, 100, [0 128, 128], 40, 90);
filled_oval_arc.move(-400, 250);
ptb.draw(filled_oval_arc);

framed_circle_arc = o_ptb.stimuli.visual.FrameCircleArc(300, [50 100 200], 180, 88, 5);
framed_circle_arc.move(400, -250);
ptb.draw(framed_circle_arc);

ptb.flip();