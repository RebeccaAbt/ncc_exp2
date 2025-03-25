classdef TestCase < matlab.unittest.TestCase
  methods(Access=protected)
    function init_ptb(testCase)
      restoredefaultpath
      addpath('../');
      o_ptb.init_ptb();
    end %function
    
    function ptb_cfg = get_ptb_cfg(testCase)
      ptb_cfg = o_ptb.PTB_Config();
      ptb_cfg.fullscreen = false;
      ptb_cfg.window_scale = 0.2;
      ptb_cfg.skip_sync_test = true;
      ptb_cfg.crappy_screen = true;
      ptb_cfg.real_experiment_sbg_cdk(false)
    end %function
    
    function init_subsystems(testCase)
      ptb_cfg = testCase.get_ptb_cfg();
      
      ptb = o_ptb.PTB.get_instance(ptb_cfg);
      ptb.setup_audio();
      ptb.setup_screen();
      ptb.setup_trigger();
      ptb.setup_response();
    end %function
    
  end %protected methods
  
  methods(TestClassSetup)
    function init_o_ptb(testCase)
      
      testCase.init_ptb();
      testCase.init_subsystems();
      
    end %function
  end %TestClassSetup methods
end %classdef