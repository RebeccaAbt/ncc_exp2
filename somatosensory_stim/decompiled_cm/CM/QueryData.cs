// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.QueryData
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System.Runtime.InteropServices;

namespace CorticalMetrics
{
  [StructLayout(LayoutKind.Sequential, Pack = 1)]
  internal struct QueryData
  {
    public byte Command;
    public byte PacketDataFieldSize;
    public byte DeviceFamily;
    public byte Type1;
    public uint Address1;
    public uint Length1;
    public byte Type2;
    public uint Address2;
    private uint Length2;
    private byte Type3;
    private uint Address3;
    private uint Length3;
    private byte Type4;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst = 33)]
    private byte[] ExtraPadBytes;
  }
}
