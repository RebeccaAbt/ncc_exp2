classdef TriggerInitTest < helpers.TestCase
  
  methods(TestClassSetup)
    function init_o_ptb(testCase)
      
      testCase.init_ptb();      
    end %function
  end %TestClassSetup methods
  
  methods(Test)
    function test_set_to_dummy(testCase)
      ptb_cfg = testCase.get_ptb_cfg();
      ptb_cfg.internal_config.trigger_subsystem = @o_ptb.subsystems.trigger.Dummy;
      
      ptb = o_ptb.PTB.get_instance(ptb_cfg);
      ptb.setup_audio();
      ptb.setup_screen();
      ptb.setup_trigger();
      ptb.setup_response();
    end %function
    
    function test_set_to_minus1(testCase)
      ptb_cfg = testCase.get_ptb_cfg();
      ptb_cfg.internal_config.trigger_subsystem = -1;
      
      ptb = o_ptb.PTB.get_instance(ptb_cfg);
      ptb.setup_audio();
      ptb.setup_screen();
      ptb.setup_trigger();
      ptb.setup_response();
    end %function
  end %Test methods
  
end

