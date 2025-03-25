// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.QuadStimulusChain
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System.Collections.Generic;

namespace CorticalMetrics
{
  public class QuadStimulusChain
  {
    public readonly List<StimulusLink> CH1;
    public readonly List<StimulusLink> CH2;
    public readonly List<StimulusLink> CH3;
    public readonly List<StimulusLink> CH4;

    public int TotalDurationMS
    {
      get
      {
        int num1 = 0;
        int num2 = QuadStimulusChain.DurationOfChain(this.CH1);
        if (num2 > num1)
          num1 = num2;
        int num3 = QuadStimulusChain.DurationOfChain(this.CH2);
        if (num3 > num1)
          num1 = num3;
        int num4 = QuadStimulusChain.DurationOfChain(this.CH3);
        if (num4 > num1)
          num1 = num4;
        int num5 = QuadStimulusChain.DurationOfChain(this.CH4);
        if (num5 > num1)
          num1 = num5;
        return num1;
      }
    }

    internal List<StimulusLink> this[int i]
    {
      get
      {
        switch (i)
        {
          case 2:
            return this.CH1;
          case 3:
            return this.CH2;
          case 4:
            return this.CH3;
          case 5:
            return this.CH4;
          default:
            return (List<StimulusLink>) null;
        }
      }
    }

    public QuadStimulusChain()
    {
      this.CH1 = new List<StimulusLink>();
      this.CH2 = new List<StimulusLink>();
      this.CH3 = new List<StimulusLink>();
      this.CH4 = new List<StimulusLink>();
    }

    public QuadStimulusChain(List<StimulusLink> ch1, List<StimulusLink> ch2, List<StimulusLink> ch3, List<StimulusLink> ch4)
    {
      this.CH1 = ch1;
      this.CH2 = ch2;
      this.CH3 = ch3;
      this.CH4 = ch4;
    }

    internal static int DurationOfChain(List<StimulusLink> chain)
    {
      double num = 0.0;
      foreach (StimulusLink stimulusLink in chain)
      {
        if (stimulusLink.Stimulus != null)
          num += stimulusLink.Stimulus.Duration;
      }
      return (int) num;
    }

    public void Clear()
    {
      this.CH1.Clear();
      this.CH2.Clear();
      this.CH3.Clear();
      this.CH4.Clear();
    }

    public void AddAll(StimulusLink link)
    {
      for (int index = 2; index < 6; ++index)
        this[index].Add(link);
    }

    public void AddAll(Stimulus s)
    {
      this.AddAll(new StimulusLink(s));
    }
  }
}
