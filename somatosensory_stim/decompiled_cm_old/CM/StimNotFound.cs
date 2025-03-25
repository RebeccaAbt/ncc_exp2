// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.StimNotFound
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System;

namespace CorticalMetrics
{
  public class StimNotFound : Exception
  {
    public StimNotFound()
    {
    }

    public StimNotFound(string message)
      : base(message)
    {
    }

    public StimNotFound(string message, Exception inner)
      : base(message, inner)
    {
    }
  }
}
