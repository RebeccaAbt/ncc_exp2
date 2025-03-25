// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.ConfigData
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System.Runtime.InteropServices;

namespace CorticalMetrics
{
  [StructLayout(LayoutKind.Sequential, Pack = 1)]
  internal struct ConfigData
  {
    public byte Command;
    public byte SubCommand;
    public short Multiplier;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst = 4)]
    public int[] OpticalGains;
    public byte AdcSampleDivisor;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst = 2)]
    public byte[] Version;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst = 39)]
    public byte[] ExtraData;

    public ConfigData(byte command)
    {
      this.Command = command;
      this.SubCommand = (byte) 0;
      this.Multiplier = (short) 0;
      this.OpticalGains = new int[4];
      this.Version = new byte[2];
      this.AdcSampleDivisor = (byte) 0;
      this.ExtraData = new byte[39];
    }

    public ConfigData(byte command, int optical_1, int optical_2, int optical_3, int optical_4)
    {
      this = new ConfigData(command);
      this.OpticalGains[0] = optical_1;
      this.OpticalGains[1] = optical_2;
      this.OpticalGains[2] = optical_3;
      this.OpticalGains[3] = optical_4;
    }
  }
}
