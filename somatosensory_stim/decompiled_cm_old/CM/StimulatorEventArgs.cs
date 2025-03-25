// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.StimulatorEventArgs
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System;

namespace CorticalMetrics
{
  public class StimulatorEventArgs : EventArgs
  {
    public StimulatorEventType EventType { get; set; }

    public int ResponseButtonPressed { get; set; }

    public long ResponseTime { get; set; }

    public bool MotorMoving { get; set; }

    public double VibrationDuration { get; set; }

    public bool ContinuouslyVibrating { get; set; }
  }
}
