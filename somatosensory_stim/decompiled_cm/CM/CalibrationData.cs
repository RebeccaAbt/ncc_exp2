// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.CalibrationData
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System;

namespace CorticalMetrics
{
  internal static class CalibrationData
  {
    public static void AnalyzeTipData(Pnt[] points, ref double M, ref double B, ref double R2)
    {
      double x1 = 0.0;
      double x2 = 0.0;
      double num1 = 0.0;
      double num2 = 0.0;
      double num3 = 0.0;
      double num4 = 0.0;
      for (int index = 0; index < points.Length; ++index)
      {
        num4 += points[index].X * points[index].Y;
        x1 += points[index].X;
        x2 += points[index].Y;
        num1 += points[index].X * points[index].X;
        num2 += points[index].Y * points[index].Y;
      }
      double num5 = num1 - x1 * x1 / (double) points.Length;
      num3 = num2 - x2 * x2 / (double) points.Length;
      double num6 = (double) points.Length * num4 - x1 * x2;
      double d = ((double) points.Length * num1 - Math.Pow(x1, 2.0)) * ((double) points.Length * num2 - Math.Pow(x2, 2.0));
      double num7 = num4 - x1 * x2 / (double) points.Length;
      M = num7 / num5;
      double num8 = x1 / (double) points.Length;
      double num9 = x2 / (double) points.Length;
      B = num9 - M * num8;
      double num10 = num6 / Math.Sqrt(d);
      R2 = num10 * num10;
    }
  }
}
