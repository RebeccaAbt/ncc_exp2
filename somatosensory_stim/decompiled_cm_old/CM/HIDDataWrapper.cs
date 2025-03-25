// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.HIDDataWrapper
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

namespace CorticalMetrics
{
  internal class HIDDataWrapper
  {
    public readonly HIDData Data;
    public StimulatorEventArgs EventArgs;

    public HIDDataWrapper(HIDData data, StimulatorEventArgs args)
    {
      this.Data = data;
      this.EventArgs = args;
    }

    public HIDDataWrapper(HIDData data)
    {
      this.Data = data;
    }
  }
}
