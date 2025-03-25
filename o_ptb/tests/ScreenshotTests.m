classdef ScreenshotTests < helpers.TestCase 
  methods(Test)
    function test_simple_screenshot(testCase)
      ptb = o_ptb.PTB.get_instance();
      fname = sprintf('%s.png', tempname);
      
      stim = o_ptb.stimuli.visual.FixationCross();
      ptb.draw(stim);
      ptb.flip();
      ptb.screenshot(fname);
      
      imread(fname);
      
      delete(fname);
      
    end %function
  end %Test methods
end %classdef