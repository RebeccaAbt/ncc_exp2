// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.DualStimulusChain
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System.Collections.Generic;

namespace CorticalMetrics
{
  internal class DualStimulusChain
  {
    public readonly List<StimulusLink> LChain;
    public readonly List<StimulusLink> RChain;

    public int TotalDurationMS
    {
      get
      {
        int num1 = 0;
        int num2 = QuadStimulusChain.DurationOfChain(this.LChain);
        if (num2 > num1)
          num1 = num2;
        int num3 = QuadStimulusChain.DurationOfChain(this.RChain);
        if (num3 > num1)
          num1 = num3;
        return num1;
      }
    }

    public DualStimulusChain()
    {
      this.LChain = new List<StimulusLink>();
      this.RChain = new List<StimulusLink>();
    }

    public DualStimulusChain(List<StimulusLink> l, List<StimulusLink> r)
    {
      this.LChain = l;
      this.RChain = r;
    }
  }
}
