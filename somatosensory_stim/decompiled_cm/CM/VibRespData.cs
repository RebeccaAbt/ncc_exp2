// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.VibRespData
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System.Runtime.InteropServices;

namespace CorticalMetrics
{
  [StructLayout(LayoutKind.Sequential, Pack = 1)]
  internal struct VibRespData
  {
    public byte Command;
    public byte SubCommand;
    public uint SampleCounter;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst = 12)]
    public ushort[] SumSquares;
    public byte SampleDivisor;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst = 33)]
    public byte[] ExtraData;

    public VibRespData(byte command)
    {
      this.Command = command;
      this.SubCommand = (byte) 0;
      this.SampleCounter = 0U;
      this.SumSquares = new ushort[12];
      this.SampleDivisor = (byte) 0;
      this.ExtraData = new byte[33];
    }
  }
}
