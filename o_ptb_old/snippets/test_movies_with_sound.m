%% clear....
clear all global
close all
restoredefaultpath;

%% init o_ptb
o_ptb.init_ptb('/home/th/git_other/Psychtoolbox-3');

%% set variables...
movie_file = '/home/th/temp/850_meters.mkv';
%movie_file = '/home/th/Downloads/grb_2.mkv';

%% get a configuration object
ptb_cfg = o_ptb.PTB_Config();

%% do the configuration
ptb_cfg.fullscreen = true;
ptb_cfg.window_scale = 0.2;
ptb_cfg.skip_sync_test = true;
ptb_cfg.hide_mouse = false;

%% init....
ptb = o_ptb.PTB.get_instance(ptb_cfg);

ptb.setup_screen();
ptb.setup_audio();

%% get movie object....
movie = o_ptb.stimuli.visual.Movie(movie_file);
snd = o_ptb.stimuli.auditory.Wav(movie_file);

%% start movie and schedule sound
snd.absmax = 0.9;

ptb.prepare_audio(snd);
ptb.schedule_audio();
ptb.play_on_flip();
movie.stop();
movie.start();

%% do the movie playing loop....
old_t = GetSecs();
movie.resync()

draw_time = [];
old_flip_time = old_t;

while movie.fetch_frame()
  ptb.draw(movie);

  %fprintf('We are out of sync: %fms\n', (movie.next_flip_time - GetSecs()) *1e3);
  
  new_t = ptb.flip(movie.next_flip_time);

  old_flip_time = movie.next_flip_time;
  
  %fprintf('Current framerate: %f\n', 1 / (new_t - old_t));
  
  old_t = new_t;
end %while

sca