// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.AdcData
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System.Runtime.InteropServices;

namespace CorticalMetrics
{
  [StructLayout(LayoutKind.Sequential, Pack = 1)]
  internal struct AdcData
  {
    public byte Command;
    public byte SubCommand;
    public byte Channel;
    public short StartingIndex;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst = 25)]
    public short[] Data;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)]
    public byte[] ExtraData;
  }
}
