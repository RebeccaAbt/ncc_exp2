// Decompiled with JetBrains decompiler
// Type: Filter.ButterworthLowPassFilter
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System;

namespace Filter
{
  internal class ButterworthLowPassFilter
  {
    private const int LowPassOrder = 4;
    private double[] inputValueModifier;
    private double[] outputValueModifier;
    private double[] inputValue;
    private double[] outputValue;
    private int valuePosition;

    public ButterworthLowPassFilter()
    {
      this.inputValueModifier = new double[4];
      this.inputValueModifier[0] = 0.098531160923927;
      this.inputValueModifier[1] = 0.295593482771781;
      this.inputValueModifier[2] = 0.295593482771781;
      this.inputValueModifier[3] = 0.098531160923927;
      this.outputValueModifier = new double[4];
      this.outputValueModifier[0] = 1.0;
      this.outputValueModifier[1] = -0.577240524806303;
      this.outputValueModifier[2] = 0.421787048689562;
      this.outputValueModifier[3] = -0.0562972364918427;
    }

    public double Filter(double inputValue)
    {
      if (this.inputValue == null && this.outputValue == null)
      {
        this.inputValue = new double[4];
        this.outputValue = new double[4];
        this.valuePosition = -1;
        for (int index = 0; index < 4; ++index)
        {
          this.inputValue[index] = inputValue;
          this.outputValue[index] = inputValue;
        }
        return inputValue;
      }
      if (this.inputValue == null || this.outputValue == null)
        throw new Exception("Both inputValue and outputValue should either be null or not null.  This should never be thrown.");
      this.valuePosition = this.IncrementLowOrderPosition(this.valuePosition);
      this.inputValue[this.valuePosition] = inputValue;
      this.outputValue[this.valuePosition] = 0.0;
      int j = this.valuePosition;
      for (int index = 0; index < 4; ++index)
      {
        this.outputValue[this.valuePosition] += this.inputValueModifier[index] * this.inputValue[j] - this.outputValueModifier[index] * this.outputValue[j];
        j = this.DecrementLowOrderPosition(j);
      }
      return this.outputValue[this.valuePosition];
    }

    private int DecrementLowOrderPosition(int j)
    {
      if (--j < 0)
        j += 4;
      return j;
    }

    private int IncrementLowOrderPosition(int position)
    {
      return (position + 1) % 4;
    }
  }
}
