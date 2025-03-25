// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.Stimulator
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Threading;
using System.Xml;

namespace CorticalMetrics
{
  internal abstract class Stimulator
  {
    protected int[] Indexes = new int[4]{ -1, -1, -1, -1 };
    protected int[] LRIndexes = new int[2]{ -1, -1 };
    protected static readonly string ConfigFileName = AppDomain.CurrentDomain.BaseDirectory + "CM.xml";
    protected static NumberFormatInfo ni = (NumberFormatInfo) null;
    protected static XmlDocument ConfigFile;
    protected string DAQ_BOARD;
    protected string D_CONTROL_LINES;
    protected string D_OPTICAL_LINES;
    protected string D_DUALOPTICAL_LINES;
    protected string D_FORCE_LINES;
    protected string D_DUALOUTPUT_LINES;
    protected string D_RESPONSE_LINES;
    protected double AMPLITUDE_MULTIPLIER;
    protected bool DataLinesConfigured;
    protected StimulatorControlMode _ControlMode;

    public bool IsSimulated { get; protected set; }

    public string UnitID { get; protected set; }

    public string UnitType { get; protected set; }

    public string DeviceName { get; protected set; }

    public long SerialNumber { get; protected set; }

    public double[,] LUT { get; protected set; }

    public double[] Accelerometer { get; protected set; }

    public double[] OpticalGains { get; protected set; }

    public double[] OpticalOffsets { get; protected set; }

    public bool CalibrationInProgress { get; protected set; }

    public StimulatorControlMode ControlMode
    {
      get
      {
        return this._ControlMode;
      }
      set
      {
        int num = (int) this.SetControlMode(value);
        this._ControlMode = value;
      }
    }

    public event StimulatorEventHandler StimulatorEvent;

    public event CalibrationProgressEventHandler CalibrationProgressEvent;

    static Stimulator()
    {
      Stimulator.ni = (NumberFormatInfo) CultureInfo.InstalledUICulture.NumberFormat.Clone();
      Stimulator.ni.NumberDecimalSeparator = ".";
    }

    protected static void SaveConfigFile()
    {
      if (Stimulator.ConfigFile == null)
        return;
      lock (Stimulator.ConfigFile)
      {
        XmlTextWriter xmlTextWriter = new XmlTextWriter(Stimulator.ConfigFileName, Encoding.UTF8)
        {
          Formatting = Formatting.Indented
        };
        Stimulator.ConfigFile.WriteTo((XmlWriter) xmlTextWriter);
        xmlTextWriter.Flush();
        xmlTextWriter.Close();
      }
    }

    public static Stimulator CreateStim()
    {
      return (Stimulator) CM_5.CreateStim();
    }

    public static Stimulator[] CreateAllStims(IEnumerable<string> exceptTheseDeviceNames)
    {
      return (Stimulator[]) new List<CM_5>(CM_5.CreateAllStims()).ToArray();
    }

    public static Stimulator[] CreateAllStims()
    {
      return Stimulator.CreateAllStims((IEnumerable<string>) null);
    }

    public abstract bool SelfTest(ref string failed);

    public abstract void GoHome();

    public virtual void SkinDetect()
    {
      this.SkinDetect(0.0, 0.0, 500.0, false);
    }

    public abstract void SkinDetect(double Lthresh, double Rthresh, double indent, bool SafetyRaise);

    public virtual void ConfigureDataLines(string stimLoc, string handUsed)
    {
      this.DataLinesConfigured = true;
    }

    public abstract bool CheckResponseDevice();

    public abstract int GetResponse(out double rt, bool UseEvents);

    public int GetResponse(bool UseEvents)
    {
      double rt;
      return this.GetResponse(out rt, UseEvents);
    }

    public int GetResponse(out double rt)
    {
      return this.GetResponse(out rt, true);
    }

    public int GetResponse()
    {
      double rt;
      return this.GetResponse(out rt, true);
    }

    public double[] Vibrate(Stimulus left, Stimulus right)
    {
      Stimulus stimulus = new Stimulus();
      return this.Vibrate(left, right, stimulus, stimulus, true);
    }

    public double[] Vibrate(Stimulus left, Stimulus right, bool UseEvents)
    {
      Stimulus stimulus = new Stimulus();
      return this.Vibrate(left, right, stimulus, stimulus, UseEvents);
    }

    public virtual double[] Vibrate(Stimulus left, Stimulus right, Stimulus left_carrier, Stimulus right_carrier, bool UseEvents)
    {
      Stimulus left1 = left.CloneUMtoMM();
      Stimulus right1 = right.CloneUMtoMM();
      Stimulus left_carrier1 = left_carrier.CloneUMtoMM();
      Stimulus right_carrier1 = right_carrier.CloneUMtoMM();
      int sample_rate = 10000;
      if (left1.Duration == 0.0 || right1.Duration == 0.0)
        return (double[]) null;
      if (left1.Duration != right1.Duration)
        return (double[]) null;
      int samples = 0;
      return this.PeakToPeakAvg(this.FiniteAnalogOut(this.D_DUALOPTICAL_LINES, this.D_DUALOUTPUT_LINES, this.GenerateSine(ref samples, sample_rate, left1, right1, left_carrier1, right_carrier1), (double) sample_rate, samples, UseEvents));
    }

    public static List<StimulusLink> GenerateRomoChain(Stimulus left)
    {
      double frequency = left.Frequency;
      double duration1 = left.Duration;
      double duration2 = left.Duration;
      if (duration2 < 40.0)
        throw new Exception("Duration Too Short For Romo Stimulus");
      Stimulus stim = left.Clone();
      stim.Frequency = 50.0;
      int delayInMs = 1000 / (int) stim.Frequency;
      stim.Duration = (double) delayInMs;
      int capacity = (int) (duration2 / (double) delayInMs) - 2;
      int num = (int) Math.Floor(duration1 / (1.0 / frequency) / 1000.0) - 2;
      List<KeyValuePair<Guid, bool>> keyValuePairList = new List<KeyValuePair<Guid, bool>>(capacity);
      for (int index = 1; index <= capacity; ++index)
        keyValuePairList.Add(new KeyValuePair<Guid, bool>(Guid.NewGuid(), num-- > 0));
      keyValuePairList.Sort((Comparison<KeyValuePair<Guid, bool>>) ((a, b) => a.Key.CompareTo(b.Key)));
      List<StimulusLink> stimulusLinkList = new List<StimulusLink>();
      stimulusLinkList.Add(new StimulusLink(stim));
      foreach (KeyValuePair<Guid, bool> keyValuePair in keyValuePairList)
      {
        if (keyValuePair.Value)
          stimulusLinkList.Add(new StimulusLink(stim));
        else
          stimulusLinkList.Add(new StimulusLink(delayInMs));
      }
      stimulusLinkList.Add(new StimulusLink(stim));
      return stimulusLinkList;
    }

    public double[] RomoVibrate(Stimulus left, Stimulus right, bool UseEvents)
    {
      double frequency1 = left.Frequency;
      double frequency2 = right.Frequency;
      double duration1 = left.Duration;
      double duration2 = right.Duration;
      double num1 = duration1 > duration2 ? duration1 : duration2;
      if (num1 < 40.0)
        throw new Exception("Duration Too Short For Romo Stimulus");
      Stimulus stim1 = left.Clone();
      Stimulus stim2 = right.Clone();
      stim2.Frequency = stim1.Frequency = 50.0;
      int delayInMs = 1000 / (int) stim1.Frequency;
      stim2.Duration = stim1.Duration = (double) delayInMs;
      int capacity = (int) (num1 / (double) delayInMs) - 2;
      int num2 = (int) Math.Floor(duration1 / (1.0 / frequency1) / 1000.0) - 2;
      int num3 = (int) Math.Floor(duration2 / (1.0 / frequency2) / 1000.0) - 2;
      List<KeyValuePair<Guid, bool>> keyValuePairList1 = new List<KeyValuePair<Guid, bool>>(capacity);
      List<KeyValuePair<Guid, bool>> keyValuePairList2 = new List<KeyValuePair<Guid, bool>>(capacity);
      for (int index = 1; index <= capacity; ++index)
      {
        keyValuePairList1.Add(new KeyValuePair<Guid, bool>(Guid.NewGuid(), num2-- > 0));
        keyValuePairList2.Add(new KeyValuePair<Guid, bool>(Guid.NewGuid(), num3-- > 0));
      }
      keyValuePairList1.Sort((Comparison<KeyValuePair<Guid, bool>>) ((a, b) => a.Key.CompareTo(b.Key)));
      keyValuePairList2.Sort((Comparison<KeyValuePair<Guid, bool>>) ((a, b) => a.Key.CompareTo(b.Key)));
      DualStimulusChain chain = new DualStimulusChain();
      chain.LChain.Add(new StimulusLink(stim1));
      foreach (KeyValuePair<Guid, bool> keyValuePair in keyValuePairList1)
      {
        if (keyValuePair.Value)
          chain.LChain.Add(new StimulusLink(stim1));
        else
          chain.LChain.Add(new StimulusLink(delayInMs));
      }
      chain.LChain.Add(new StimulusLink(stim1));
      chain.RChain.Add(new StimulusLink(stim2));
      foreach (KeyValuePair<Guid, bool> keyValuePair in keyValuePairList2)
      {
        if (keyValuePair.Value)
          chain.RChain.Add(new StimulusLink(stim2));
        else
          chain.RChain.Add(new StimulusLink(delayInMs));
      }
      chain.RChain.Add(new StimulusLink(stim2));
      return this.ChainVibration(chain);
    }

    public double[] TojVibrate(Stimulus pulse, int ISI, bool LeftFirst)
    {
      Stimulus carrier = new Stimulus(0.0, pulse.Frequency, 0.0, pulse.Indent);
      return this.TojVibrate(pulse, carrier, ISI, LeftFirst);
    }

    public double[] TojVibrate1(Stimulus pulse, Stimulus carrier, int ISI, bool LeftFirst)
    {
      Stimulus stimulus1 = pulse.CloneUMtoMM();
      Stimulus stimulus2 = carrier.CloneUMtoMM();
      Stimulus stimulus3 = new Stimulus(0.0, carrier.Frequency, 1000.0, pulse.Indent);
      int sample_rate = 10000;
      if (stimulus1.Duration == 0.0)
        return (double[]) null;
      stimulus1.Duration = (double) (int) (1000.0 / stimulus1.Frequency);
      stimulus2.Duration = 1000.0;
      int samples1 = 10000;
      int num1 = ISI * 10;
      int samples2 = (int) stimulus1.Duration * 10;
      double[,] sine1 = this.GenerateSine(ref samples1, sample_rate, stimulus2, stimulus2, stimulus3, stimulus3);
      double[,] sine2 = this.GenerateSine(ref samples2, sample_rate, stimulus1, stimulus1, stimulus3, stimulus3);
      double[,] outdata = new double[2, samples1];
      int num2 = LeftFirst ? 0 : 1;
      int num3 = num1 + 2 * samples2;
      int num4 = (int) Math.Floor((double) ((samples1 - num3) / 2));
      int num5 = (int) Math.Ceiling((double) ((samples1 - num3) / 2));
      int index1 = 0;
      for (int index2 = 0; index2 < num4; ++index2)
      {
        outdata[0, index1] = sine1[0, index2];
        outdata[1, index1] = sine1[1, index2];
        ++index1;
      }
      for (int index2 = 0; index2 < samples2; ++index2)
      {
        if (LeftFirst)
        {
          outdata[0, index1] = sine1[0, index1] + sine2[0, index2];
          outdata[1, index1] = sine1[1, index1];
        }
        else
        {
          outdata[0, index1] = sine1[0, index1];
          outdata[1, index1] = sine1[1, index1] + sine2[1, index2];
        }
        ++index1;
      }
      for (int index2 = 0; index2 < num1; ++index2)
      {
        outdata[0, index1] = sine1[0, index1];
        outdata[1, index1] = sine1[1, index1];
        ++index1;
      }
      for (int index2 = 0; index2 < samples2; ++index2)
      {
        if (LeftFirst)
        {
          outdata[0, index1] = sine1[0, index1];
          outdata[1, index1] = sine1[1, index1] + sine2[1, index2];
        }
        else
        {
          outdata[0, index1] = sine1[0, index1] + sine2[0, index2];
          outdata[1, index1] = sine1[1, index1];
        }
        ++index1;
      }
      for (int index2 = 0; index2 < num5; ++index2)
      {
        outdata[0, index1] = sine1[0, index2];
        outdata[1, index1] = sine1[1, index2];
        ++index1;
      }
      return this.PeakToPeakAvg(this.FiniteAnalogOut(this.D_OPTICAL_LINES, this.D_DUALOUTPUT_LINES, outdata, (double) sample_rate, samples1, true));
    }

    public double[] TojVibrate(Stimulus pulse, Stimulus carrier, int ISI, bool LeftFirst)
    {
      Stimulus stimulus = new Stimulus(0.0, pulse.Frequency, 0.0, pulse.Indent);
      return this.TojVibrate(pulse, carrier, carrier, ISI, LeftFirst);
    }

    public double[] TojVibrate(Stimulus pulse, Stimulus leftcarrier, Stimulus rightcarrier, int ISI, bool LeftFirst)
    {
      Stimulus stimulus1 = pulse.CloneUMtoMM();
      Stimulus left = leftcarrier.CloneUMtoMM();
      Stimulus right = rightcarrier.CloneUMtoMM();
      Stimulus stimulus2 = new Stimulus(0.0, leftcarrier.Frequency, 1000.0, pulse.Indent);
      int sample_rate = 10000;
      if (stimulus1.Duration == 0.0)
        return (double[]) null;
      stimulus1.Duration = (double) (int) (1000.0 / stimulus1.Frequency);
      left.Duration = 1000.0;
      right.Duration = 1000.0;
      int samples1 = 10000;
      int num1 = ISI * 10;
      int samples2 = (int) stimulus1.Duration * 10;
      double[,] sine1 = this.GenerateSine(ref samples1, sample_rate, left, right, stimulus2, stimulus2);
      double[,] sine2 = this.GenerateSine(ref samples2, sample_rate, stimulus1, stimulus1, stimulus2, stimulus2);
      double[,] outdata = new double[2, samples1];
      int index1 = LeftFirst ? 0 : 1;
      int num2 = num1 + samples2;
      int num3 = (int) Math.Floor((double) ((samples1 - num2) / 2));
      for (int index2 = 0; index2 < 2; ++index2)
      {
        int index3 = 0;
        for (int index4 = 0; index4 < num3; ++index4)
        {
          outdata[index1, index4] = sine1[index1, index4];
          ++index3;
        }
        for (int index4 = 0; index4 < samples2; ++index4)
        {
          outdata[index1, index3] = sine2[0, index4] + sine1[index1, index3];
          ++index3;
        }
        for (int index4 = index3; index4 < samples1; ++index4)
          outdata[index1, index4] = sine1[index1, index4];
        index1 = LeftFirst ? 1 : 0;
        num3 += num1;
      }
      return this.PeakToPeakAvg(this.FiniteAnalogOut(this.D_OPTICAL_LINES, this.D_DUALOUTPUT_LINES, outdata, (double) sample_rate, samples1, true));
    }

    public double[] GappedTojVibrate(Stimulus pulse, Stimulus leftcarrier, Stimulus rightcarrier, int ISI, bool LeftFirst, int GapDuration)
    {
      Stimulus stimulus1 = pulse.CloneUMtoMM();
      Stimulus left = leftcarrier.CloneUMtoMM();
      Stimulus right = rightcarrier.CloneUMtoMM();
      Stimulus stimulus2 = new Stimulus(0.0, leftcarrier.Frequency, 1000.0, pulse.Indent);
      int sample_rate = 10000;
      if (stimulus1.Duration == 0.0)
        return (double[]) null;
      stimulus1.Duration = (double) (int) (1000.0 / stimulus1.Frequency);
      left.Duration = 1000.0;
      right.Duration = 1000.0;
      int samps_per_chan = 10000;
      int num1 = ISI * 10;
      int samples1 = (int) stimulus1.Duration * 10;
      double[,] sine1 = this.GenerateSine(ref samples1, sample_rate, stimulus1, stimulus1, stimulus2, stimulus2);
      double[,] outdata = new double[2, samps_per_chan];
      int index1 = LeftFirst ? 0 : 1;
      int samples2 = num1 + samples1;
      int num2 = GapDuration * 10;
      int samples3 = (int) Math.Floor((double) (samps_per_chan - samples2) / 2.0) - num2;
      stimulus2.Duration = left.Duration = right.Duration = (double) samples3 / 10.0;
      double[,] sine2 = this.GenerateSine(ref samples3, sample_rate, left, right, stimulus2, stimulus2);
      stimulus2.Duration = left.Duration = right.Duration = (double) samples2 / 10.0;
      double[,] sine3 = this.GenerateSine(ref samples2, sample_rate, left, right, stimulus2, stimulus2);
      for (int index2 = 0; index2 < samples3; ++index2)
      {
        outdata[0, index2] = sine2[0, index2];
        outdata[1, index2] = sine2[1, index2];
      }
      int num3 = num2 + samples3;
      for (int index2 = samples3; index2 < num3; ++index2)
        outdata[0, index2] = outdata[1, index2] = 0.0;
      int index3 = num3;
      for (int index2 = 0; index2 < samples2; ++index2)
      {
        outdata[index1, index3] = index2 >= samples1 ? sine3[index1, index2] : sine1[index1, index2] + sine3[index1, index2];
        ++index3;
      }
      int index4 = LeftFirst ? 1 : 0;
      int index5 = num3;
      for (int index2 = 0; index2 < samples2; ++index2)
      {
        outdata[index4, index5] = index2 >= num1 ? sine3[index4, index2] + sine1[index4, index2 - num1] : sine3[index4, index2];
        ++index5;
      }
      for (int index2 = 0; index2 < num2; ++index2)
      {
        outdata[0, index5] = outdata[1, index5] = 0.0;
        ++index5;
      }
      for (int index2 = 0; index2 < samples3; ++index2)
      {
        outdata[0, index5] = sine2[0, index2];
        outdata[1, index5] = sine2[1, index2];
        ++index5;
      }
      return this.PeakToPeakAvg(this.FiniteAnalogOut(this.D_OPTICAL_LINES, this.D_DUALOUTPUT_LINES, outdata, (double) sample_rate, samps_per_chan, true));
    }

    public double[] ChainVibration(DualStimulusChain chain)
    {
      return this.ChainVibration(chain, true, false);
    }

    public double[] ChainVibration(DualStimulusChain chain, bool eventsOn)
    {
      return this.ChainVibration(chain, eventsOn, false);
    }

    public virtual double[] ChainVibration(DualStimulusChain chain, bool EventsOn, bool flipLandR)
    {
      int sample_rate = 10000;
      int num = sample_rate / 1000;
      int samps_per_chan = chain.TotalDurationMS * num;
      double[,] outdata = new double[2, samps_per_chan];
      List<StimulusLink>[] stimulusLinkListArray;
      if (flipLandR)
        stimulusLinkListArray = new List<StimulusLink>[2]
        {
          chain.RChain,
          chain.LChain
        };
      else
        stimulusLinkListArray = new List<StimulusLink>[2]
        {
          chain.LChain,
          chain.RChain
        };
      for (int index1 = 0; index1 < stimulusLinkListArray.Length; ++index1)
      {
        int index2 = 0;
        foreach (StimulusLink stimulusLink in stimulusLinkListArray[index1])
        {
          double[] sine = this.GenerateSine(sample_rate, index1 == 0, stimulusLink.Stimulus.CloneUMtoMM(), stimulusLink.Carrier.CloneUMtoMM());
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
      return this.PeakToPeakAvg(this.FiniteAnalogOut(this.D_OPTICAL_LINES, this.D_DUALOUTPUT_LINES, outdata, (double) sample_rate, samps_per_chan, EventsOn));
    }

    protected virtual StimulatorControlMode SetControlMode(StimulatorControlMode value)
    {
      throw new NotImplementedException("Error...calling cm4 method");
    }

    protected double[] PeakToPeakAvg(double[,] waves)
    {
      int[] numArray1 = waves.GetLength(0) == 2 ? this.LRIndexes : this.Indexes;
      double[] numArray2 = new double[waves.GetLength(0)];
      for (int index1 = 0; index1 < waves.GetLength(0); ++index1)
      {
        double[] numArray3 = new double[3]
        {
          -1000.0,
          -1000.0,
          -1000.0
        };
        double[] numArray4 = new double[3]
        {
          1000.0,
          1000.0,
          1000.0
        };
        int num = waves.GetLength(1) / 5;
        for (int index2 = 0; index2 < num; ++index2)
        {
          double wave1 = waves[index1, num + index2];
          double wave2 = waves[index1, 2 * num + index2];
          double wave3 = waves[index1, 3 * num + index2];
          if (wave1 > numArray3[0])
            numArray3[0] = wave1;
          if (wave1 < numArray4[0])
            numArray4[0] = wave1;
          if (wave2 > numArray3[1])
            numArray3[1] = wave2;
          if (wave2 < numArray4[1])
            numArray4[1] = wave2;
          if (wave3 > numArray3[2])
            numArray3[2] = wave3;
          if (wave3 < numArray4[2])
            numArray4[2] = wave3;
        }
        numArray2[index1] = (numArray3[0] - numArray4[0] + (numArray3[1] - numArray4[1]) + (numArray3[2] - numArray4[2])) / 3.0 / this.OpticalGains[numArray1[index1]];
      }
      return numArray2;
    }

    protected virtual double ScaleByLUT(double freq, double amp, bool right)
    {
      if (amp == 0.0)
        return 0.0;
      if (this.CalibrationInProgress)
        return amp;
      int index1 = 3;
      if (int.Parse(this.UnitType) > 2)
        return amp;
      if (right)
        index1 = 1;
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

    protected double[,] GenerateSine(ref int samples, int sample_rate, Stimulus left, Stimulus right, Stimulus left_carrier, Stimulus right_carrier)
    {
      if (left.Duration == 0.0 || right.Duration == 0.0)
        return (double[,]) null;
      if (left.Duration != right.Duration)
        return (double[,]) null;
      double num1 = 0.0;
      double num2 = 0.0;
      double num3;
      double num4;
      if (this.ControlMode == StimulatorControlMode.Force)
      {
        num3 = 10.0 * left.Amplitude;
        num1 = 10.0 * left_carrier.Amplitude;
        num4 = 10.0 * right.Amplitude;
        num2 = 10.0 * right_carrier.Amplitude;
        if (this.UnitType == "3")
        {
          num3 *= this.OpticalGains[this.LRIndexes[0]];
          num1 *= this.OpticalGains[this.LRIndexes[0]];
          num4 *= this.OpticalGains[this.LRIndexes[1]];
          num2 *= this.OpticalGains[this.LRIndexes[1]];
        }
      }
      else
      {
        num3 = this.ScaleByLUT(left.Frequency, left.Amplitude, false);
        if (left_carrier.Amplitude != 0.0)
          num1 = this.ScaleByLUT(left_carrier.Frequency, left_carrier.Amplitude, false);
        num4 = this.ScaleByLUT(right.Frequency, right.Amplitude, true);
        if (right_carrier.Amplitude != 0.0)
          num2 = this.ScaleByLUT(right_carrier.Frequency, right_carrier.Amplitude, true);
      }
      samples = (int) Math.Truncate((double) sample_rate / 1000.0 * left.Duration);
      double[,] numArray = new double[2, samples];
      for (int index = 0; index < numArray.GetLength(1); ++index)
      {
        numArray[0, index] = num3 * Math.Sin((double) (index * 2) * Math.PI / (double) sample_rate * left.Frequency);
        if (num1 > 0.0)
          numArray[0, index] += num1 * Math.Sin((double) (index * 2) * Math.PI / (double) sample_rate * left_carrier.Frequency);
        numArray[1, index] = num4 * Math.Sin((double) (index * 2) * Math.PI / (double) sample_rate * right.Frequency);
        if (num2 > 0.0)
          numArray[1, index] += num2 * Math.Sin((double) (index * 2) * Math.PI / (double) sample_rate * right_carrier.Frequency);
      }
      return numArray;
    }

    protected double[] GenerateSine(int sample_rate, bool right, Stimulus stim, Stimulus carrier)
    {
      double num1;
      double num2;
      if (this.ControlMode == StimulatorControlMode.Force && this.UnitType == "3")
      {
        num1 = stim.Amplitude * 10.0;
        num2 = carrier.Amplitude * 10.0;
      }
      else
      {
        num1 = this.ScaleByLUT(stim.Frequency, stim.Amplitude, right);
        num2 = this.ScaleByLUT(carrier.Frequency, carrier.Amplitude, right);
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

    protected double[,] FiniteAnalogOut(string InLines, string OutLines, double[,] outdata, double rate, int samps_per_chan, bool UseEvents)
    {
      if (!this.IsSimulated)
        throw new NotImplementedException("No DAQMX");
      if (UseEvents)
        this.TriggerStimulatorEvent(new StimulatorEventArgs()
        {
          EventType = StimulatorEventType.FiniteVibration,
          VibrationDuration = (double) samps_per_chan / rate
        });
      Thread.Sleep(samps_per_chan * 1000 / (int) rate);
      return new double[outdata.GetLength(0), outdata.GetLength(1)];
    }

    public void TriggerStimulatorEvent(StimulatorEventArgs e)
    {
      // ISSUE: reference to a compiler-generated field
      if (this.StimulatorEvent == null)
        return;
      // ISSUE: reference to a compiler-generated field
      this.StimulatorEvent((object) this, e);
    }

    public void ClearStimulatorEvents()
    {
      // ISSUE: reference to a compiler-generated field
      this.StimulatorEvent = (StimulatorEventHandler) null;
    }

    public void TriggerCalibrationProgressEvent(CalibrationProgressArgs e)
    {
      // ISSUE: reference to a compiler-generated field
      if (this.CalibrationProgressEvent == null)
        return;
      // ISSUE: reference to a compiler-generated field
      this.CalibrationProgressEvent((object) this, e);
    }

    protected double[] StringToDoubleArray(string Input, string separator)
    {
      string[] separator1 = new string[1]{ separator };
      string[] strArray = Input.Split(separator1, StringSplitOptions.None);
      double[] numArray = new double[strArray.Length];
      for (int index = 0; index < strArray.Length; ++index)
        numArray[index] = double.Parse(strArray[index], (IFormatProvider) Stimulator.ni);
      return numArray;
    }

    public virtual void Calibrate(int[] Frequencies, double[] DesiredAmplitudes)
    {
    }

    public virtual void CleanUpTasks()
    {
    }

    public virtual void ConfigureTrigger(List<int> triggers)
    {
    }

    public virtual void DisconnectTriggers(bool force)
    {
    }
  }
}
