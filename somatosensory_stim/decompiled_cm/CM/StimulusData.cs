// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.StimulusData
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System.Runtime.InteropServices;

namespace CorticalMetrics
{
  [StructLayout(LayoutKind.Sequential, Pack = 1)]
  internal struct StimulusData
  {
    public short Amplitude;
    public byte Frequency;
    public short CarrierAmplitude;
    public byte CarrierFrequency;

    public StimulusData(short amp, byte freq)
    {
      this.Amplitude = amp;
      this.Frequency = freq;
      this.CarrierAmplitude = (short) 0;
      this.CarrierFrequency = (byte) 10;
    }
  }
}
