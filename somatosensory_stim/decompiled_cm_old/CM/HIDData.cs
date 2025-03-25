// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.HIDData
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System.Runtime.InteropServices;

namespace CorticalMetrics
{
  [StructLayout(LayoutKind.Sequential, Pack = 1)]
  internal struct HIDData
  {
    public byte Command;
    public byte SubCommand;
    public ushort Duration;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst = 4)]
    public StimulusData[] Stims;
    public byte BufferFree;
    public byte TriggerChans;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst = 34)]
    public byte[] ExtraData;

    public HIDData(byte c)
    {
      this.Command = c;
      this.SubCommand = (byte) 0;
      this.Duration = (ushort) 0;
      this.Stims = new StimulusData[4];
      for (int index = 0; index < this.Stims.Length; ++index)
      {
        this.Stims[index].Amplitude = (short) -1;
        this.Stims[index].CarrierAmplitude = (short) 0;
        this.Stims[index].CarrierFrequency = (byte) 10;
        this.Stims[index].Frequency = (byte) 10;
      }
      this.BufferFree = (byte) 0;
      this.TriggerChans = (byte) 0;
      this.ExtraData = new byte[34];
    }

    public HIDData(byte c, byte sc)
    {
      this = new HIDData(c);
      this.SubCommand = sc;
    }
  }
}
