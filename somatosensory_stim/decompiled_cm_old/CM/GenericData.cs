// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.GenericData
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System.Runtime.InteropServices;

namespace CorticalMetrics
{
  [StructLayout(LayoutKind.Sequential, Pack = 1)]
  internal struct GenericData
  {
    public byte Command;
    public uint Address;
    public byte Size;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst = 2)]
    private byte[] PadBytes;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst = 56)]
    public byte[] Data;
  }
}
