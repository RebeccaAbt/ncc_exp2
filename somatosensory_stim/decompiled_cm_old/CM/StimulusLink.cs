// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.StimulusLink
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

namespace CorticalMetrics
{
  public class StimulusLink
  {
    private Stimulus blank = new Stimulus(0.0, 10.0, 0.0, 0.0);
    public Stimulus Stimulus;
    public Stimulus Carrier;

    public StimulusLink()
    {
      this.Carrier = this.Stimulus = this.blank;
    }

    public StimulusLink(Stimulus stim)
      : this()
    {
      this.Stimulus = stim;
    }

    public StimulusLink(Stimulus stim, Stimulus carrier)
      : this(stim)
    {
      this.Carrier = carrier;
    }

    public StimulusLink(int delayInMs)
      : this()
    {
      this.Stimulus.Duration = (double) delayInMs;
    }

    internal StimulusLink(int delayInMs, int whatever)
      : this(delayInMs)
    {
      this.Stimulus.Amplitude = -1.0;
    }
  }
}
