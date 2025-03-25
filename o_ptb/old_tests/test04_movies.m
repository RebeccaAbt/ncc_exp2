%% clear....
clear all global
close all

%% init o_ptb
init_o_ptb_paths('../');

%% set variables...
movie_file = '/home/th/owncloud/sbg/temp/00011_cut.mkv';
%movie_file = '/home/th/Downloads/grb_2.mkv';

%% get a configuration object
ptb_cfg = o_ptb.PTB_Config();

%% do the configuration
ptb_cfg.fullscreen = false;
ptb_cfg.window_scale = 0.2;
ptb_cfg.skip_sync_test = true;
ptb_cfg.hide_mouse = false;

%% init....
ptb = o_ptb.PTB.get_instance(ptb_cfg);

ptb.setup_screen;

%% get movie object....
movie = o_ptb.stimuli.visual.Movie(movie_file);

%% add a gaussian blur shader....
movie.add_gauss_blur(10, 121);

%% start movie...
movie.stop();
movie.start();

%% do the movie playing loop....
old_t = GetSecs();
movie.resync()

draw_time = [];
old_flip_time = old_t;

while movie.fetch_frame()
  ptb.draw(movie);

  fprintf('We are out of sync: %fms\n', (movie.next_flip_time - GetSecs()) *1e3);
  
  new_t = ptb.flip(movie.next_flip_time);

  old_flip_time = movie.next_flip_time;
  
  fprintf('Current framerate: %f\n', 1 / (new_t - old_t));
  
  old_t = new_t;
end %while