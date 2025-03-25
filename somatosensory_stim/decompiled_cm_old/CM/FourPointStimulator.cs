// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.FourPointStimulator
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.Xml;

namespace CorticalMetrics
{
  internal class FourPointStimulator : Stimulator
  {
    protected string D_FAN_LINES = "/port2/line5:6";
    protected string D_QUADOUTPUT_LINES = "/ao0:3";
    private readonly List<int> PFIsConnectedToCtr1 = new List<int>();
    private const string D_PIEZO_POWER_LINE = "/port1/line0";

    public Thread FanPwmThread { get; protected set; }

    public string InputTriggerLine { get; private set; }

    public FourPointStimulator()
    {
    }

    public FourPointStimulator(string dev)
    {
      if (dev.Equals("simulate"))
        this.IsSimulated = true;
      this.InitDevice(dev);
    }

    public override void GoHome()
    {
    }

    public override void SkinDetect(double Lthresh, double Rthresh, double indent, bool SafetyRaise)
    {
    }

    public override int GetResponse(out double rt, bool UseEvents)
    {
      rt = -1.0;
      StimulatorEventArgs e = new StimulatorEventArgs();
      if (UseEvents)
      {
        e.EventType = StimulatorEventType.Response;
        e.ResponseButtonPressed = -1;
        this.TriggerStimulatorEvent(e);
      }
      return -1;
    }

    public override bool CheckResponseDevice()
    {
      return true;
    }

    public override bool SelfTest(ref string failed)
    {
      return true;
    }

    public override void ConfigureDataLines(string stimLoc, string handUsed)
    {
      string str1 = stimLoc.Remove(0, 3);
      string str2 = str1;
      string[] strArray = str1.Replace("D", "").Split(',');
      this.LRIndexes[0] = this.LRIndexes[1] = -1;
      if (!(handUsed == "R"))
      {
        if (handUsed == "L")
        {
          this.Indexes = new int[4]{ 3, 2, 1, 0 };
          this.D_QUADOUTPUT_LINES = "/ao0:3";
          this.D_OPTICAL_LINES = "/ai1," + this.DeviceName + "/ai3," + this.DeviceName + "/ai5," + this.DeviceName + "/ai7";
          this.D_FORCE_LINES = "/ai17," + this.DeviceName + "/ai19," + this.DeviceName + "/ai21," + this.DeviceName + "/ai23";
          if (strArray.Length != 0)
          {
            int num = int.Parse(strArray[0]);
            if (strArray.Length == 2)
            {
              this.LRIndexes[0] = this.Indexes[int.Parse(strArray[1]) - 2];
              this.LRIndexes[1] = this.Indexes[num - 2];
              str2 = "D" + strArray[1] + ",D" + strArray[0];
            }
            else
              this.LRIndexes[0] = this.Indexes[num - 2];
            str2 = str2.Replace("D2", "/ao0").Replace("D3", "/ao1").Replace("D4", "/ao2").Replace("D5", "/ao3").Replace(",", "," + this.DeviceName);
            this.D_DUALOPTICAL_LINES = "/ai3," + this.DeviceName + "/ai1";
          }
        }
      }
      else
      {
        this.Indexes = new int[4]{ 0, 1, 2, 3 };
        this.D_QUADOUTPUT_LINES = "/ao3:0";
        this.D_OPTICAL_LINES = "/ai7," + this.DeviceName + "/ai5," + this.DeviceName + "/ai3," + this.DeviceName + "/ai1";
        this.D_FORCE_LINES = "/ai23," + this.DeviceName + "/ai21," + this.DeviceName + "/ai19," + this.DeviceName + "/ai17";
        if (strArray.Length != 0 && !(strArray[0] == ""))
        {
          this.LRIndexes[0] = this.Indexes[int.Parse(strArray[0]) - 2];
          string str3 = "/ao" + (5 - (this.LRIndexes[0] + 2)).ToString();
          if (strArray.Length == 2)
            this.LRIndexes[1] = this.Indexes[int.Parse(strArray[1]) - 2];
          str2 = str2.Replace("D2", "/ao3").Replace("D3", "/ao2").Replace("D4", "/ao1").Replace("D5", "/ao0").Replace(",", "," + this.DeviceName);
          this.D_DUALOPTICAL_LINES = "/ai7," + this.DeviceName + "/ai5";
        }
      }
      this.D_DUALOUTPUT_LINES = str2;
      this.DataLinesConfigured = true;
    }

    protected override StimulatorControlMode SetControlMode(StimulatorControlMode value)
    {
      throw new NotImplementedException("Old CM4");
    }

    private void InitDevice(string DevString)
    {
      if (!this.IsSimulated)
        return;
      this.UnitID = "0";
      this.UnitType = "0";
      this.OpticalGains = new double[4];
      this.LUT = new double[1, 13];
    }

    protected void ParseLUT(string temp)
    {
      if (temp.Length <= 0)
        return;
      char[] separator1 = new char[1]{ 'N' };
      char[] separator2 = new char[1]{ 'T' };
      string[] strArray1 = temp.Split(separator1, StringSplitOptions.None);
      this.LUT = new double[strArray1.Length, 13];
      for (int index1 = 0; index1 < strArray1.Length; ++index1)
      {
        string[] strArray2 = strArray1[index1].Split(separator2, StringSplitOptions.None);
        for (int index2 = 0; index2 < strArray2.Length; ++index2)
          this.LUT[index1, index2] = double.Parse(strArray2[index2], (IFormatProvider) Stimulator.ni);
      }
    }

    public virtual void DisconnectInputTrigger()
    {
      this.InputTriggerLine = string.Empty;
    }

    public double[] Vibrate(Stimulus D2, Stimulus D3, Stimulus D4, Stimulus D5)
    {
      Stimulus stimulus = new Stimulus();
      return this.Vibrate(D2, D3, D4, D5, stimulus, stimulus, stimulus, stimulus, true);
    }

    public virtual double[] Vibrate(Stimulus D2, Stimulus D3, Stimulus D4, Stimulus D5, Stimulus D2Carrier, Stimulus D3Carrier, Stimulus D4Carrier, Stimulus D5Carrier, bool UseEvents)
    {
      Stimulus D2_1 = D2.CloneUMtoMM();
      Stimulus D3_1 = D3.CloneUMtoMM();
      Stimulus D4_1 = D4.CloneUMtoMM();
      Stimulus D5_1 = D5.CloneUMtoMM();
      D2Carrier.CloneUMtoMM();
      D3Carrier.CloneUMtoMM();
      D4Carrier.CloneUMtoMM();
      D5Carrier.CloneUMtoMM();
      int sample_rate = 20000;
      int samples = 0;
      return this.PeakToPeakAvg(this.FiniteAnalogOut(this.D_OPTICAL_LINES, this.D_QUADOUTPUT_LINES, this.GenerateSine(ref samples, sample_rate, D2_1, D3_1, D4_1, D5_1, D2Carrier, D3Carrier, D4Carrier, D5Carrier), (double) sample_rate, samples, UseEvents));
    }

    public double[,] ContinuousDynamicAmpVibration(Stimulus std, Stimulus test, int[] testOnDigits, bool amp_is_changing, double std_ss, double test_ss, double max_val, double min_val, double delay, out double rt, out double DL, ref int ButtonPushed)
    {
      return this.ContinuousDynamicAmpVibration(std, test, testOnDigits, amp_is_changing, std_ss, test_ss, max_val, min_val, delay, out rt, out DL, ref ButtonPushed, 20000.0, 4000, this.D_QUADOUTPUT_LINES);
    }

    public virtual double[,] ContinuousDynamicAmpVibration(Stimulus std, Stimulus test, int[] testOnDigits, bool amp_is_changing, double std_ss, double test_ss, double max_val, double min_val, double delay, out double rt, out double DL, ref int ButtonPushed, double rate, int samps_per_chan, string OutLines)
    {
      if (!this.IsSimulated)
        throw new NotImplementedException("Old cm4 method");
      rt = 0.0;
      DL = 0.0;
      ButtonPushed = 1;
      return (double[,]) null;
    }

    public double[,] ContinuousDynamicAmpVibration(Stimulus higher, Stimulus lower, Stimulus fixed1, Stimulus fixed2, FourPointStimulator.ContinuousDynamicAmp[] Digits, bool amp_is_changing, double higher_ss, double lower_ss, double max_val, double min_val, double delay, out double rt, out double DL, ref int ButtonPushed)
    {
      return this.ContinuousDynamicAmpVibration(higher, lower, fixed1, fixed2, Digits, amp_is_changing, higher_ss, lower_ss, max_val, min_val, delay, out rt, out DL, ref ButtonPushed, 20000.0, 4000, this.D_QUADOUTPUT_LINES);
    }

    public virtual double[,] ContinuousDynamicAmpVibration(Stimulus higher, Stimulus lower, Stimulus fixed1, Stimulus fixed2, FourPointStimulator.ContinuousDynamicAmp[] Digits, bool amp_is_changing, double higher_ss, double lower_ss, double max_val, double min_val, double delay, out double rt, out double DL, ref int ButtonPushed, double rate, int samps_per_chan, string OutLines)
    {
      if (!this.IsSimulated)
        throw new NotImplementedException("Old cm4 method");
      rt = 0.0;
      DL = 0.0;
      ButtonPushed = 1;
      return (double[,]) null;
    }

    public double[,] WeirdContinuousRampSSA(Stimulus higher, Stimulus lower, Stimulus fixed1, Stimulus fixed2, FourPointStimulator.ContinuousDynamicAmp[] Digits, bool amp_is_changing, double higher_ss, double lower_ss, double max_val, double min_val, double delay, out double rt, out double DL, ref int ButtonPushed)
    {
      rt = 0.0;
      DL = 0.0;
      return (double[,]) null;
    }

    public double[,] WeirdContinuousRampSSA(Stimulus test, Stimulus std, Stimulus fixed1, Stimulus fixed2, FourPointStimulator.ContinuousDynamicAmp[] Digits, double test_starting_amp, double delay, out double rt, out double DL, ref int ButtonPushed, double rate, int samps_per_chan, string OutLines)
    {
      if (!this.IsSimulated)
        throw new NotImplementedException("Old cm4 method");
      rt = 0.0;
      DL = 0.0;
      ButtonPushed = 1;
      return (double[,]) null;
    }

    public double[] MotionIllusionVibrate(Stimulus pulse, Stimulus carrier, int ISI, int[] DigitOrder)
    {
      return this.MotionIllusionVibrate(pulse, pulse, pulse, pulse, carrier, ISI, DigitOrder);
    }

    public virtual double[] MotionIllusionVibrate(Stimulus D2pulse, Stimulus D3pulse, Stimulus D4pulse, Stimulus D5pulse, Stimulus carrier, int ISI, int[] DigitOrder)
    {
      Stimulus D2 = D2pulse.CloneUMtoMM();
      Stimulus D3 = D3pulse.CloneUMtoMM();
      Stimulus D4 = D4pulse.CloneUMtoMM();
      Stimulus D5 = D5pulse.CloneUMtoMM();
      Stimulus stimulus1 = carrier.CloneUMtoMM();
      Stimulus stimulus2 = new Stimulus(0.0, carrier.Frequency, 1000.0, D2pulse.Indent);
      int sample_rate = 10000;
      if (D2.Duration == 0.0)
        return (double[]) null;
      D3.Duration = D4.Duration = D5.Duration = D2.Duration = (double) (int) (1000.0 / D2.Frequency);
      int num1 = 5000;
      int num2 = ISI * 10;
      int samples1 = (int) D2.Duration * 10;
      int samples2 = DigitOrder.Length * samples1 + num1 + (DigitOrder.Length - 1) * num2 + num1;
      stimulus1.Duration = (double) (samples2 / 10);
      double[,] sine1 = this.GenerateSine(ref samples2, sample_rate, stimulus1, stimulus1, stimulus1, stimulus1, stimulus2, stimulus2, stimulus2, stimulus2);
      double[,] sine2 = this.GenerateSine(ref samples1, sample_rate, D2, D3, D4, D5, stimulus2, stimulus2, stimulus2, stimulus2);
      double[,] outdata = new double[4, samples2];
      List<int>[] intListArray = new List<int>[4];
      for (int index = 0; index < intListArray.Length; ++index)
        intListArray[index] = new List<int>(50);
      for (int index = 0; index < DigitOrder.Length; ++index)
        intListArray[DigitOrder[index] - 2].Add(num1 + index * (samples1 + num2));
      for (int index1 = 0; index1 < outdata.GetLength(0); ++index1)
      {
        int num3 = 0;
        for (int index2 = 0; index2 < intListArray[index1].Count; ++index2)
        {
          for (int index3 = num3; index3 < intListArray[index1][index2]; ++index3)
            outdata[index1, index3] = sine1[index1, index3];
          int num4 = intListArray[index1][index2];
          for (int index3 = 0; index3 < sine2.GetLength(1); ++index3)
            outdata[index1, num4 + index3] = sine2[index1, index3] + sine1[index1, num4 + index3];
          num3 = num4 + sine2.GetLength(1);
        }
        for (int index2 = num3; index2 < outdata.GetLength(1); ++index2)
          outdata[index1, index2] = sine1[index1, index2];
      }
      return this.PeakToPeakAvg(this.FiniteAnalogOut(this.D_OPTICAL_LINES, this.D_QUADOUTPUT_LINES, outdata, (double) sample_rate, samples2, true));
    }

    public virtual double[] ChainVibration(QuadStimulusChain chain)
    {
      return this.ChainVibration(chain, true);
    }

    public virtual double[] ChainVibration(QuadStimulusChain chain, bool EventsOn)
    {
      int sample_rate = 10000;
      int num = sample_rate / 1000;
      int samps_per_chan = chain.TotalDurationMS * num;
      double[,] outdata = new double[4, samps_per_chan];
      List<StimulusLink>[] stimulusLinkListArray = new List<StimulusLink>[4]
      {
        chain.CH1,
        chain.CH2,
        chain.CH3,
        chain.CH4
      };
      for (int index1 = 0; index1 < stimulusLinkListArray.Length; ++index1)
      {
        int index2 = 0;
        foreach (StimulusLink stimulusLink in stimulusLinkListArray[index1])
        {
          double[] sine = this.GenerateSine(sample_rate, index1 + 2, stimulusLink.Stimulus.CloneUMtoMM(), stimulusLink.Carrier.CloneUMtoMM());
          int index3 = 0;
          while (index3 < sine.Length)
          {
            outdata[index1, index2] = sine[index3];
            ++index3;
            ++index2;
          }
        }
        for (int index3 = index2; index3 < outdata.GetLength(1); ++index3)
          outdata[index1, index3] = 0.0;
      }
      return this.PeakToPeakAvg(this.FiniteAnalogOut(this.D_OPTICAL_LINES, this.D_QUADOUTPUT_LINES, outdata, (double) sample_rate, samps_per_chan, EventsOn));
    }

    protected double[] GenerateSine(int sample_rate, int Digit, Stimulus stim, Stimulus carrier)
    {
      if (Digit < 2 || Digit > 5)
        throw new Exception("INVALID DIGIT PASSED TO GENERATE SINE METHOD");
      Digit = this.Indexes[Digit - 2];
      double num1;
      double num2;
      if (this.ControlMode == StimulatorControlMode.Force && this.UnitType == "3")
      {
        num1 = stim.Amplitude * 10.0;
        num2 = carrier.Amplitude * 10.0;
      }
      else
      {
        num1 = this.ScaleByLUT(stim.Frequency, stim.Amplitude, Digit) * this.OpticalGains[Digit] / 2.0;
        num2 = this.ScaleByLUT(carrier.Frequency, carrier.Amplitude, Digit) * this.OpticalGains[Digit] / 2.0;
      }
      double[] numArray = new double[(int) Math.Truncate((double) (sample_rate / 1000) * stim.Duration)];
      if (num1 == 0.0 && num2 == 0.0)
      {
        for (int index = 0; index < numArray.Length; ++index)
          numArray[index] = 0.0;
      }
      else
      {
        for (int index = 0; index < numArray.Length; ++index)
        {
          numArray[index] = num1 * Math.Sin((double) (index * 2) * Math.PI / (double) sample_rate * stim.Frequency);
          if (num2 > 0.0)
            numArray[index] += num2 * Math.Sin((double) (index * 2) * Math.PI / (double) sample_rate * carrier.Frequency);
        }
      }
      return numArray;
    }

    protected double[,] GenerateSine(ref int samples, int sample_rate, Stimulus D2, Stimulus D3, Stimulus D4, Stimulus D5, Stimulus D2Carrier, Stimulus D3Carrier, Stimulus D4Carrier, Stimulus D5Carrier)
    {
      if (D2.Duration == 0.0 || D4.Duration == 0.0 || (D3.Duration == 0.0 || D5.Duration == 0.0))
        return (double[,]) null;
      if (D2.Duration != D3.Duration && D2.Duration != D4.Duration && D2.Duration != D5.Duration)
        return (double[,]) null;
      double num1;
      double num2;
      double num3;
      double num4;
      double num5;
      double num6;
      double num7;
      double num8;
      if (this.ControlMode == StimulatorControlMode.Force)
      {
        if (this.UnitType == "3")
        {
          num1 = D2.Amplitude * 10.0 * this.OpticalGains[this.Indexes[0]];
          num2 = D2Carrier.Amplitude * 10.0 * this.OpticalGains[this.Indexes[0]];
          num3 = D3.Amplitude * 10.0 * this.OpticalGains[this.Indexes[1]];
          num4 = D3Carrier.Amplitude * 10.0 * this.OpticalGains[this.Indexes[1]];
          num5 = D4.Amplitude * 10.0 * this.OpticalGains[this.Indexes[2]];
          num6 = D4Carrier.Amplitude * 10.0 * this.OpticalGains[this.Indexes[2]];
          num7 = D5.Amplitude * 10.0 * this.OpticalGains[this.Indexes[3]];
          num8 = D5Carrier.Amplitude * 10.0 * this.OpticalGains[this.Indexes[3]];
        }
        else
        {
          num1 = D2.Amplitude * 10.0;
          num2 = D2Carrier.Amplitude * 10.0;
          num3 = D3.Amplitude * 10.0;
          num4 = D3Carrier.Amplitude * 10.0;
          num5 = D4.Amplitude * 10.0;
          num6 = D4Carrier.Amplitude * 10.0;
          num7 = D5.Amplitude * 10.0;
          num8 = D5Carrier.Amplitude * 10.0;
        }
      }
      else
      {
        num1 = this.ScaleByLUT(D2.Frequency, D2.Amplitude, this.Indexes[0]) * this.OpticalGains[this.Indexes[0]] / 2.0;
        num2 = this.ScaleByLUT(D2Carrier.Frequency, D2Carrier.Amplitude, this.Indexes[0]) * this.OpticalGains[this.Indexes[0]] / 2.0;
        num3 = this.ScaleByLUT(D3.Frequency, D3.Amplitude, this.Indexes[1]) * this.OpticalGains[this.Indexes[1]] / 2.0;
        num4 = this.ScaleByLUT(D3Carrier.Frequency, D3Carrier.Amplitude, this.Indexes[1]) * this.OpticalGains[this.Indexes[1]] / 2.0;
        num5 = this.ScaleByLUT(D4.Frequency, D4.Amplitude, this.Indexes[2]) * this.OpticalGains[this.Indexes[2]] / 2.0;
        num6 = this.ScaleByLUT(D4Carrier.Frequency, D4Carrier.Amplitude, this.Indexes[2]) * this.OpticalGains[this.Indexes[2]] / 2.0;
        num7 = this.ScaleByLUT(D5.Frequency, D5.Amplitude, this.Indexes[3]) * this.OpticalGains[this.Indexes[3]] / 2.0;
        num8 = this.ScaleByLUT(D5Carrier.Frequency, D5Carrier.Amplitude, this.Indexes[3]) * this.OpticalGains[this.Indexes[3]] / 2.0;
      }
      samples = (int) Math.Truncate((double) sample_rate / 1000.0 * D2.Duration);
      double[,] numArray = new double[4, samples];
      double num9 = 0.0;
      for (int index = 0; index < numArray.GetLength(1); ++index)
      {
        numArray[0, index] = num1 * Math.Sin((double) (index * 2) * Math.PI / (double) sample_rate * D2.Frequency) + num9;
        if (num2 > 0.0)
          numArray[0, index] += num2 * Math.Sin((double) (index * 2) * Math.PI / (double) sample_rate * D2Carrier.Frequency);
        numArray[1, index] = num3 * Math.Sin((double) (index * 2) * Math.PI / (double) sample_rate * D3.Frequency) + num9;
        if (num4 > 0.0)
          numArray[1, index] += num4 * Math.Sin((double) (index * 2) * Math.PI / (double) sample_rate * D3Carrier.Frequency);
        numArray[2, index] = num5 * Math.Sin((double) (index * 2) * Math.PI / (double) sample_rate * D4.Frequency) + num9;
        if (num6 > 0.0)
          numArray[2, index] += num6 * Math.Sin((double) (index * 2) * Math.PI / (double) sample_rate * D4Carrier.Frequency);
        numArray[3, index] = num7 * Math.Sin((double) (index * 2) * Math.PI / (double) sample_rate * D5.Frequency) + num9;
        if (num8 > 0.0)
          numArray[3, index] += num8 * Math.Sin((double) (index * 2) * Math.PI / (double) sample_rate * D5Carrier.Frequency);
      }
      return numArray;
    }

    protected override double ScaleByLUT(double freq, double amp, bool right)
    {
      if (!right)
        return this.ScaleByLUT(freq, amp, this.LRIndexes[0]) * this.OpticalGains[this.LRIndexes[0]] / 2.0;
      return this.ScaleByLUT(freq, amp, this.LRIndexes[1]) * this.OpticalGains[this.LRIndexes[1]] / 2.0;
    }

    protected double ScaleByLUT(double freq, double amp, int Tip)
    {
      if (amp < 0.05 && freq < 50.0 || (this.CalibrationInProgress || this.LUT == null))
        return amp;
      int index1 = 3 * Tip + 1;
      double num = 1000.0;
      int index2 = 0;
      for (int index3 = 0; index3 < this.LUT.GetLength(0); ++index3)
      {
        if (Math.Abs(freq - this.LUT[index3, 0]) < num)
        {
          index2 = index3;
          num = Math.Abs(freq - this.LUT[index3, 0]);
        }
        if (num == 0.0)
          break;
      }
      return amp * this.LUT[index2, index1] + this.LUT[index2, index1 + 1];
    }

    public override void Calibrate(int[] Frequencies, double[] DesiredAmplitudes)
    {
      this.Calibrate(Frequencies, DesiredAmplitudes, this.UnitType.Contains(".2"));
    }

    private void Calibrate(int[] Frequencies, double[] DesiredAmplitudes, bool TwoTips)
    {
      if (this.UnitID == "3" || this.IsSimulated)
        return;
      this.ControlMode = StimulatorControlMode.Position;
      Thread.Sleep(1000);
      double[][] numArray1 = new double[Frequencies.Length][];
      StringBuilder stringBuilder = new StringBuilder();
      CalibrationProgressArgs e = new CalibrationProgressArgs()
      {
        PercentComplete = 0.0
      };
      this.TriggerCalibrationProgressEvent(e);
      double num1 = (double) (DesiredAmplitudes.Length * Frequencies.Length) / 100.0;
      double num2 = 0.0;
      for (int index1 = 0; index1 < Frequencies.Length; ++index1)
      {
        numArray1[index1] = new double[13];
        numArray1[index1][0] = (double) Frequencies[index1];
        Stimulus stimulus = new Stimulus(0.0, numArray1[index1][0], 1000.0, 0.0);
        Pnt[] points1 = new Pnt[DesiredAmplitudes.Length];
        Pnt[] points2 = new Pnt[DesiredAmplitudes.Length];
        Pnt[] points3 = new Pnt[DesiredAmplitudes.Length];
        Pnt[] points4 = new Pnt[DesiredAmplitudes.Length];
        this.CalibrationInProgress = true;
        for (int index2 = 0; index2 < DesiredAmplitudes.Length; ++index2)
        {
          stimulus.Amplitude = DesiredAmplitudes[index2];
          double[] numArray2 = !TwoTips ? this.Vibrate(stimulus, stimulus, stimulus, stimulus) : this.Vibrate(stimulus, stimulus);
          points1[index2].Y = points2[index2].Y = points3[index2].Y = points4[index2].Y = DesiredAmplitudes[index2] / 1000.0;
          if (TwoTips)
          {
            points1[index2].X = numArray2[0];
            points2[index2].X = numArray2[1];
            points3[index2].X = points4[index2].X = 0.0;
          }
          else
          {
            points1[index2].X = numArray2[0];
            points2[index2].X = numArray2[1];
            points3[index2].X = numArray2[2];
            points4[index2].X = numArray2[3];
          }
          e.PercentComplete = ++num2 / num1;
          this.TriggerCalibrationProgressEvent(e);
          Thread.Sleep(250);
        }
        this.CalibrationInProgress = false;
        CalibrationData.AnalyzeTipData(points1, ref numArray1[index1][1], ref numArray1[index1][2], ref numArray1[index1][3]);
        CalibrationData.AnalyzeTipData(points2, ref numArray1[index1][4], ref numArray1[index1][5], ref numArray1[index1][6]);
        if (TwoTips)
        {
          numArray1[index1][7] = numArray1[index1][8] = numArray1[index1][10] = numArray1[index1][11] = 0.0;
          numArray1[index1][9] = numArray1[index1][12] = 1.0;
        }
        else
        {
          CalibrationData.AnalyzeTipData(points3, ref numArray1[index1][7], ref numArray1[index1][8], ref numArray1[index1][9]);
          CalibrationData.AnalyzeTipData(points4, ref numArray1[index1][10], ref numArray1[index1][11], ref numArray1[index1][12]);
        }
      }
      for (int index1 = 0; index1 < numArray1.Length; ++index1)
      {
        int index2;
        for (index2 = 0; index2 < numArray1[index1].Length - 1; ++index2)
          stringBuilder.Append(Math.Round(numArray1[index1][index2], 5)).Append("T");
        stringBuilder.Append(numArray1[index1][index2]).Append("N");
      }
      XmlNode elementById = (XmlNode) Stimulator.ConfigFile.GetElementById("D" + this.SerialNumber.ToString());
      elementById["LUT"].InnerText = stringBuilder.Remove(stringBuilder.Length - 1, 1).ToString();
      Stimulator.SaveConfigFile();
      this.ParseLUT(elementById["LUT"].InnerText);
    }

    public enum ContinuousDynamicAmp
    {
      Fixed1,
      Fixed2,
      Low,
      High,
    }
  }
}
