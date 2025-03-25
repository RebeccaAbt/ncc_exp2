// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.CM_5
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Threading;

namespace CorticalMetrics
{
  internal class CM_5 : FourPointStimulator
  {
    internal static int DEVICE_USB_ID_VENDOR = 17476;
    private static int DEVICE_USB_ID_PID = 5;
    internal static int DEVICE_USB_ID_PID_BOOTLOAD = 1;
    private static byte PGAIN = 1;
    private static byte IGAIN = 1;
    private static byte DGAIN = 1;
    private static int SAMPLE_RATE = 20000;
    private static readonly List<CM_5> AllCM5s = new List<CM_5>();
    private CM5Device Device;
    public bool TwoPointed;
    private bool Vibrating;
    private int waitingForTriggeredStimulus;

    private CM_5(CM5Device dev)
      : this(dev, false)
    {
    }

    private CM_5(CM5Device dev, bool powerUp)
    {
      this.Device = dev;
      if (!powerUp)
        return;
      int num = (int) this.PowerUp();
    }

    ~CM_5()
    {
    }

    public override void CleanUpTasks()
    {
      int num = (int) this.PowerDown();
      this.ControlMode = StimulatorControlMode.Force;
      this.Device.Dispose();
    }

    public override void ConfigureDataLines(string stimLoc, string handUsed)
    {
      string[] strArray = stimLoc.Remove(0, 3).Replace("D", "").Split(',');
      this.Indexes = new int[4]{ 0, 1, 2, 3 };
      if (!this.TwoPointed)
      {
        if (handUsed == "L")
          Array.Reverse((Array) this.Indexes);
        this.LRIndexes[0] = this.LRIndexes[1] = -1;
        this.LRIndexes[0] = this.Indexes[int.Parse(strArray[0]) - 2];
        if (strArray.Length == 2)
          this.LRIndexes[1] = this.Indexes[int.Parse(strArray[1]) - 2];
        Array.Sort<int>(this.LRIndexes);
      }
      this.DataLinesConfigured = true;
    }

    protected override StimulatorControlMode SetControlMode(StimulatorControlMode mode)
    {
      if (mode == this._ControlMode)
        return mode;
      if (mode == StimulatorControlMode.Force)
      {
        int num = (int) this.SendCommand(CM_5.CommandCodes.SetControlMode, (byte) 0);
        return StimulatorControlMode.Force;
      }
      return (int) this.SendCommand(CM_5.CommandCodes.SetControlMode, (byte) 1) < 128 ? StimulatorControlMode.Position : StimulatorControlMode.Force;
    }

    public List<double> CalibrateVibrate(double freq, double amp, byte chan)
    {
      Stimulus stimulus = new Stimulus(amp, freq, 500.0, 0.0);
      QuadStimulusChain chain = new QuadStimulusChain();
      for (int index = 2; index < 6; ++index)
        chain[index].Add(new StimulusLink(new Stimulus(amp, freq, 500.0, 500.0)));
      this.FiniteVibration(this.CChainVibration(chain, CM_5.CommandCodes.CalibrateVibration), true);
      return this.ReceiveAdcData(chan);
    }

    public override void Calibrate(int[] Frequencies, double[] DesiredAmplitudes)
    {
      this.ConfigureDataLines("UL-D2,D3", "R");
      double[][] numArray = new double[Frequencies.Length][];
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
        numArray[index1] = new double[13];
        numArray[index1][0] = (double) Frequencies[index1];
        Stimulus stim = new Stimulus(0.0, numArray[index1][0], 500.0, 0.0);
        Pnt[] points1 = new Pnt[DesiredAmplitudes.Length];
        Pnt[] points2 = new Pnt[DesiredAmplitudes.Length];
        Pnt[] points3 = new Pnt[DesiredAmplitudes.Length];
        Pnt[] points4 = new Pnt[DesiredAmplitudes.Length];
        Pnt[][] pntArray = new Pnt[4][]
        {
          points1,
          points2,
          points3,
          points4
        };
        this.CalibrationInProgress = true;
        for (int index2 = 0; index2 < DesiredAmplitudes.Length; ++index2)
        {
          stim.Amplitude = DesiredAmplitudes[index2];
          points1[index2].Y = points2[index2].Y = points3[index2].Y = points4[index2].Y = DesiredAmplitudes[index2] / 1000.0;
          for (int index3 = 0; index3 < 4; ++index3)
          {
            QuadStimulusChain chain = new QuadStimulusChain();
            chain[index3 + 2].Add(new StimulusLink(stim));
            for (int index4 = 2; index4 < 6; ++index4)
            {
              if (chain[index4].Count == 0)
                chain[index4].Add(new StimulusLink(500));
            }
            this.FiniteVibration(this.CChainVibration(chain, CM_5.CommandCodes.CalibrateVibration), true);
            List<double> adcData = this.ReceiveAdcData((byte) index3);
            pntArray[index3][index2].X = this.SinglePeakToPeakAvg(adcData);
            Thread.Sleep(250);
          }
          e.PercentComplete = ++num2 / num1;
          this.TriggerCalibrationProgressEvent(e);
        }
        this.CalibrationInProgress = false;
        CalibrationData.AnalyzeTipData(points1, ref numArray[index1][1], ref numArray[index1][2], ref numArray[index1][3]);
        CalibrationData.AnalyzeTipData(points2, ref numArray[index1][4], ref numArray[index1][5], ref numArray[index1][6]);
        CalibrationData.AnalyzeTipData(points3, ref numArray[index1][7], ref numArray[index1][8], ref numArray[index1][9]);
        CalibrationData.AnalyzeTipData(points4, ref numArray[index1][10], ref numArray[index1][11], ref numArray[index1][12]);
      }
    }

    private double SinglePeakToPeakAvg(List<double> data)
    {
      double[] numArray1 = new double[3]
      {
        -1000.0,
        -1000.0,
        -1000.0
      };
      double[] numArray2 = new double[3]
      {
        1000.0,
        1000.0,
        1000.0
      };
      int num1 = data.Count / 5;
      for (int index = 0; index < num1; ++index)
      {
        double num2 = data[num1 + index];
        double num3 = data[2 * num1 + index];
        double num4 = data[3 * num1 + index];
        if (num2 > numArray1[0])
          numArray1[0] = num2;
        if (num2 < numArray2[0])
          numArray2[0] = num2;
        if (num3 > numArray1[1])
          numArray1[1] = num3;
        if (num3 < numArray2[1])
          numArray2[1] = num3;
        if (num4 > numArray1[2])
          numArray1[2] = num4;
        if (num4 < numArray2[2])
          numArray2[2] = num4;
      }
      return (numArray1[0] - numArray2[0] + (numArray1[1] - numArray2[1]) + (numArray1[2] - numArray2[2])) / 3.0;
    }

    public override double[] Vibrate(Stimulus D2, Stimulus D3, Stimulus D4, Stimulus D5, Stimulus D2Carrier, Stimulus D3Carrier, Stimulus D4Carrier, Stimulus D5Carrier, bool UseEvents)
    {
      return this.ChainVibration(new QuadStimulusChain()
      {
        CH1 = {
          new StimulusLink(D2, D2Carrier)
        },
        CH2 = {
          new StimulusLink(D3, D3Carrier)
        },
        CH3 = {
          new StimulusLink(D4, D4Carrier)
        },
        CH4 = {
          new StimulusLink(D5, D5Carrier)
        }
      }, UseEvents);
    }

    public override double[] Vibrate(Stimulus left, Stimulus right, Stimulus left_carrier, Stimulus right_carrier, bool UseEvents)
    {
      return this.ChainVibration(new DualStimulusChain()
      {
        LChain = {
          new StimulusLink(left, left_carrier)
        },
        RChain = {
          new StimulusLink(right, right_carrier)
        }
      }, UseEvents, false);
    }

    public override double[] ChainVibration(DualStimulusChain chain, bool EventsOn, bool flipLandR)
    {
      QuadStimulusChain chain1 = new QuadStimulusChain();
      List<StimulusLink>[] stimulusLinkListArray1 = new List<StimulusLink>[4]
      {
        chain1.CH1,
        chain1.CH2,
        chain1.CH3,
        chain1.CH4
      };
      List<StimulusLink>[] stimulusLinkListArray2 = new List<StimulusLink>[2]
      {
        chain.LChain,
        chain.RChain
      };
      if (flipLandR)
        Array.Reverse((Array) stimulusLinkListArray2);
      stimulusLinkListArray1[this.LRIndexes[0]].AddRange((IEnumerable<StimulusLink>) stimulusLinkListArray2[0]);
      stimulusLinkListArray1[this.LRIndexes[1]].AddRange((IEnumerable<StimulusLink>) stimulusLinkListArray2[1]);
      List<StimulusLink> stimulusLinkList = new List<StimulusLink>();
      for (int index = 0; index < stimulusLinkListArray2[0].Count; ++index)
        stimulusLinkList.Add(new StimulusLink((int) stimulusLinkListArray2[0][index].Stimulus.Duration));
      for (int index = 0; index < stimulusLinkListArray1.Length; ++index)
      {
        if (stimulusLinkListArray1[index].Count == 0)
          stimulusLinkListArray1[index].AddRange((IEnumerable<StimulusLink>) stimulusLinkList);
      }
      return this.FiniteVibration(this.CChainVibration(chain1), EventsOn);
    }

    public override double[] ChainVibration(QuadStimulusChain chain, bool EventsOn)
    {
      return this.ChainVibration(chain, EventsOn, false, true);
    }

    public double[] ChainVibration(QuadStimulusChain chain, bool EventsOn, bool inputTrigger, bool outputTrigger)
    {
      return this.FiniteVibration(this.CChainVibration(chain, CM_5.CommandCodes.Vibrate, inputTrigger, outputTrigger), EventsOn);
    }

    private double StepValue(double val, double ss, double minOrMax, bool Min)
    {
      val += ss;
      if (Min)
      {
        if (val >= minOrMax)
          return val;
        return minOrMax;
      }
      if (val <= minOrMax)
        return val;
      return minOrMax;
    }

    public List<HIDDataWrapper> CChainVibration(QuadStimulusChain chain)
    {
      return this.CChainVibration(chain, CM_5.CommandCodes.Vibrate);
    }

    private List<HIDDataWrapper> CChainVibration(QuadStimulusChain chain, CM_5.CommandCodes command)
    {
      return this.CChainVibration(chain, command, false, false);
    }

    private List<HIDDataWrapper> CChainVibration(QuadStimulusChain chain, CM_5.CommandCodes command, bool inputTrigger, bool outputTrigger)
    {
      List<StimulusLink>[] stimulusLinkListArray = new List<StimulusLink>[4]
      {
        chain.CH1,
        chain.CH2,
        chain.CH3,
        chain.CH4
      };
      int totalDurationMs = chain.TotalDurationMS;
      foreach (List<StimulusLink> stimulusLinkList in stimulusLinkListArray)
      {
        int num = 0;
        foreach (StimulusLink stimulusLink in stimulusLinkList)
          num += (int) stimulusLink.Stimulus.Duration;
        if (num < totalDurationMs)
          stimulusLinkList.Add(new StimulusLink(totalDurationMs - num));
      }
      SortedDictionary<int, List<Tuple>> sortedDictionary = new SortedDictionary<int, List<Tuple>>();
      for (int index1 = 0; index1 < stimulusLinkListArray.Length; ++index1)
      {
        List<StimulusLink> stimulusLinkList = stimulusLinkListArray[index1];
        int key = 0;
        for (int index2 = 0; index2 < stimulusLinkList.Count; ++index2)
        {
          StimulusLink stimulusLink = stimulusLinkList[index2];
          if (sortedDictionary.ContainsKey(key))
            sortedDictionary[key].Add(new Tuple(index1, index2));
          else
            sortedDictionary.Add(key, new List<Tuple>()
            {
              new Tuple(index1, index2)
            });
          key += (int) stimulusLink.Stimulus.Duration;
        }
      }
      int num1 = 0;
      List<int> intList = new List<int>((IEnumerable<int>) sortedDictionary.Keys);
      List<HIDDataWrapper> hidDataWrapperList = new List<HIDDataWrapper>();
      bool[] flagArray = new bool[4];
      bool flag = false;
      for (int index1 = 0; index1 < intList.Count; ++index1)
      {
        int index2 = intList[index1];
        byte sc = index1 == intList.Count - 1 ? (byte) 0 : (byte) 1;
        HIDData data = new HIDData((byte) command, sc);
        if (index1 < intList.Count - 1)
        {
          double num2 = (double) (intList[index1 + 1] - index2);
          if (num2 > 25000.0)
            throw new InvalidDataException("Duration too long");
          data.Duration = (ushort) num2;
        }
        foreach (Tuple tuple in sortedDictionary[index2])
        {
          if ((int) data.Duration == 0)
          {
            double duration = stimulusLinkListArray[tuple.Item1][tuple.Item2].Stimulus.Duration;
            if (duration > 25000.0)
              throw new InvalidDataException("Duration too long");
            data.Duration = (ushort) duration;
          }
          if (outputTrigger && !flagArray[tuple.Item1] && stimulusLinkListArray[tuple.Item1][tuple.Item2].Stimulus.Amplitude > 0.0)
          {
            flagArray[tuple.Item1] = true;
            data.TriggerChans |= (byte) (1 << tuple.Item1);
          }
          data.Stims[tuple.Item1].Amplitude = (short) stimulusLinkListArray[tuple.Item1][tuple.Item2].Stimulus.Amplitude;
          data.Stims[tuple.Item1].Frequency = (byte) stimulusLinkListArray[tuple.Item1][tuple.Item2].Stimulus.Frequency;
          data.Stims[tuple.Item1].CarrierAmplitude = (short) stimulusLinkListArray[tuple.Item1][tuple.Item2].Carrier.Amplitude;
          data.Stims[tuple.Item1].CarrierFrequency = (byte) stimulusLinkListArray[tuple.Item1][tuple.Item2].Carrier.Frequency;
        }
        num1 = index2;
        if (inputTrigger && !flag)
        {
          data.TriggerChans |= (byte) 16;
          flag = true;
        }
        hidDataWrapperList.Add(new HIDDataWrapper(data));
      }
      return hidDataWrapperList;
    }

    public override double[,] ContinuousDynamicAmpVibration(Stimulus higher, Stimulus lower, Stimulus fixed1, Stimulus fixed2, FourPointStimulator.ContinuousDynamicAmp[] Digits, bool amp_is_changing, double higher_ss, double lower_ss, double max_val, double min_val, double delay, out double rt, out double DL, ref int ButtonPushed, double rate, int samps_per_chan, string OutLines)
    {
      Stimulus stimulus1 = higher.Clone();
      Stimulus stimulus2 = lower.Clone();
      Stimulus stimulus3 = fixed1.Clone();
      Stimulus stimulus4 = fixed2.Clone();
      Stopwatch stopwatch = new Stopwatch();
      Stimulus stimulus5 = new Stimulus();
      if (amp_is_changing)
      {
        stimulus1.Duration = 200.0;
        stimulus2.Duration = 200.0;
        stimulus3.Duration = 200.0;
        stimulus4.Duration = 200.0;
      }
      else
      {
        stimulus1.Duration = 1000.0;
        stimulus2.Duration = 1000.0;
        stimulus3.Duration = 1000.0;
        stimulus4.Duration = 1000.0;
      }
      QuadStimulusChain chain = new QuadStimulusChain();
      double num1 = amp_is_changing ? stimulus1.Amplitude : stimulus1.Frequency;
      double num2 = amp_is_changing ? stimulus2.Amplitude : stimulus2.Frequency;
      double num3 = higher_ss == 0.0 ? 0.0 : Math.Ceiling(Math.Abs(max_val - num1) / higher_ss);
      double num4 = lower_ss == 0.0 ? 0.0 : Math.Ceiling(Math.Abs(min_val - num2) / lower_ss);
      int num5 = num3 > num4 ? (int) num3 : (int) num4;
      int num6 = num5 > 256 ? 256 : num5;
      List<StimulusLink> stimulusLinkList1 = new List<StimulusLink>();
      List<StimulusLink> stimulusLinkList2 = new List<StimulusLink>();
      List<StimulusLink> stimulusLinkList3 = new List<StimulusLink>();
      List<StimulusLink> stimulusLinkList4 = new List<StimulusLink>();
      if (delay > 0.0)
      {
        stimulusLinkList1.Add(new StimulusLink((int) delay));
        stimulusLinkList2.Add(new StimulusLink((int) delay));
      }
      stimulusLinkList3.Add(new StimulusLink(stimulus3.Clone()));
      stimulusLinkList4.Add(new StimulusLink(stimulus4.Clone()));
      double val1 = amp_is_changing ? stimulus1.Amplitude : stimulus1.Frequency;
      double val2 = amp_is_changing ? stimulus2.Amplitude : stimulus2.Frequency;
      for (int index = 0; index < num6; ++index)
      {
        if (index >= 1)
        {
          val1 = this.StepValue(val1, higher_ss, max_val, false);
          val2 = this.StepValue(val2, lower_ss, min_val, true);
          if (amp_is_changing)
          {
            stimulus1.Amplitude = val1;
            stimulus2.Amplitude = val2;
          }
          else
          {
            stimulus1.Frequency = val1;
            stimulus2.Frequency = val2;
          }
        }
        stimulusLinkList1.Add(new StimulusLink(stimulus1.Clone()));
        stimulusLinkList2.Add(new StimulusLink(stimulus2.Clone()));
        stimulusLinkList3.Add(new StimulusLink((int) stimulus1.Duration, 1));
        stimulusLinkList4.Add(new StimulusLink((int) stimulus1.Duration, 1));
      }
      stimulus3.Duration = stimulus4.Duration = stimulus2.Duration = stimulus1.Duration = 25000.0;
      stimulusLinkList1.Add(new StimulusLink(stimulus1.Clone()));
      stimulusLinkList2.Add(new StimulusLink(stimulus2.Clone()));
      stimulusLinkList3.Add(new StimulusLink(stimulus3.Clone()));
      stimulusLinkList4.Add(new StimulusLink(stimulus4.Clone()));
      stimulusLinkList1.Add(new StimulusLink(stimulus1.Clone()));
      stimulusLinkList2.Add(new StimulusLink(stimulus2.Clone()));
      stimulusLinkList3.Add(new StimulusLink(stimulus3.Clone()));
      stimulusLinkList4.Add(new StimulusLink(stimulus4.Clone()));
      int index1 = -1;
      int index2 = -1;
      for (int index3 = 0; index3 < 4; ++index3)
      {
        int index4 = index3 + 2;
        switch (Digits[index3])
        {
          case FourPointStimulator.ContinuousDynamicAmp.Fixed1:
            chain[index4].AddRange((IEnumerable<StimulusLink>) stimulusLinkList3);
            break;
          case FourPointStimulator.ContinuousDynamicAmp.Fixed2:
            chain[index4].AddRange((IEnumerable<StimulusLink>) stimulusLinkList4);
            break;
          case FourPointStimulator.ContinuousDynamicAmp.Low:
            index1 = index3;
            chain[index4].AddRange((IEnumerable<StimulusLink>) stimulusLinkList2);
            break;
          case FourPointStimulator.ContinuousDynamicAmp.High:
            index2 = index3;
            chain[index4].AddRange((IEnumerable<StimulusLink>) stimulusLinkList1);
            break;
        }
      }
      int totalDurationMs = chain.TotalDurationMS;
      List<HIDDataWrapper> data = this.CChainVibration(chain);
      for (int index3 = 1; index3 < data.Count; ++index3)
      {
        HIDDataWrapper hidDataWrapper = data[index3];
        if ((int) hidDataWrapper.Data.Stims[index1].Amplitude > -1 || (int) hidDataWrapper.Data.Stims[index2].Amplitude > -1)
        {
          hidDataWrapper.EventArgs = new StimulatorEventArgs()
          {
            EventType = StimulatorEventType.ContinuousVibrationDelayOver
          };
          break;
        }
      }
      ButtonPushed = -1;
      stopwatch.Start();
      int index5 = this.LongVibration(data, ref ButtonPushed, new StimulatorEventArgs()
      {
        EventType = StimulatorEventType.ContinuousVibration,
        ContinuouslyVibrating = true
      });
      stopwatch.Stop();
      bool flag = ButtonPushed < 0;
      this.TriggerStimulatorEvent(new StimulatorEventArgs()
      {
        EventType = StimulatorEventType.ContinuousVibration,
        ContinuouslyVibrating = false
      });
      rt = (double) stopwatch.ElapsedMilliseconds;
      DL = (double) ((int) data[index5].Data.Stims[index2].Amplitude - (int) data[index5].Data.Stims[index1].Amplitude);
      return (double[,]) null;
    }

    public override double[,] ContinuousDynamicAmpVibration(Stimulus std, Stimulus test, int[] testOnDigits, bool amp_is_changing, double std_ss, double test_ss, double max_val, double min_val, double delay, out double rt, out double DL, ref int ButtonPushed, double rate, int samps_per_chan, string OutLines)
    {
      throw new NotImplementedException();
    }

    public override double[] MotionIllusionVibrate(Stimulus D2pulse, Stimulus D3pulse, Stimulus D4pulse, Stimulus D5pulse, Stimulus carrier, int ISI, int[] DigitOrder)
    {
      throw new NotImplementedException();
    }

    private void InitDevice()
    {
      this.UnitID = "";
      this.UnitType = "5";
      this.DeviceName = "";
    }

    public static CM_5 CreateNoPowerStim()
    {
      return new CM_5(new CM5Device(CM_5.DEVICE_USB_ID_VENDOR, CM_5.DEVICE_USB_ID_PID), false);
    }

    public static CM_5 CreateStim()
    {
      return CM_5.CreateStim(0);
    }

    public static CM_5 SimulateStim()
    {
      return new CM_5((CM5Device) null, false);
    }

    public static CM_5 CreateStim(int index)
    {
      CM_5.ListStims();
      if (index < CM_5.AllCM5s.Count)
        return CM_5.AllCM5s[index];
      return (CM_5) null;
    }

    public static IEnumerable<CM_5> CreateAllStims()
    {
      CM_5.ListStims();
      return (IEnumerable<CM_5>) CM_5.AllCM5s;
    }

    public static CM_BootLoader CreateBootloaderStim()
    {
      CM5Device dev;
      try
      {
        dev = new CM5Device(CM_5.DEVICE_USB_ID_VENDOR, CM_5.DEVICE_USB_ID_PID_BOOTLOAD);
      }
      catch
      {
        return (CM_BootLoader) null;
      }
      if (dev != null)
        return new CM_BootLoader(dev);
      return (CM_BootLoader) null;
    }

    public static CM_5 CommissionStimulator(int serialNumber, double ch1OptGain, double ch2OptGain, double ch3OptGain, double ch4OptGain)
    {
      CM5Device dev = new CM5Device(CM_5.DEVICE_USB_ID_VENDOR, CM_5.DEVICE_USB_ID_PID);
      if (dev != null)
      {
        CM_5 cm5 = new CM_5(dev, false);
        if (cm5 != null)
        {
          ConfigData configData = cm5.PowerUpRaw();
          if ((int) configData.Command > (int) sbyte.MaxValue)
          {
            short multiplier = configData.Multiplier;
            if (!cm5.SetSerialNumber(serialNumber))
              return (CM_5) null;
            if ((int) cm5.WriteOpticalGains((int) multiplier, ch1OptGain, ch2OptGain, ch3OptGain, ch4OptGain) > (int) sbyte.MaxValue)
              return (CM_5) null;
            int num = (int) cm5.SetPID(CM_5.PGAIN, CM_5.IGAIN, CM_5.DGAIN);
            return cm5;
          }
          int num1 = (int) cm5.SetPID(CM_5.PGAIN, CM_5.IGAIN, CM_5.DGAIN);
        }
      }
      return (CM_5) null;
    }

    public void Initialize()
    {
      this.Initialize(false);
    }

    public void Initialize(bool inForceMode)
    {
      this.ConfigureDataLines("UL-D2,D3", "R");
      int num = (int) this.PowerUp();
      if (inForceMode)
        return;
      this.ControlMode = StimulatorControlMode.Position;
    }

    public void Deinitialize()
    {
      this.CleanUpTasks();
    }

    public double[] ReadADC(short[] offsets)
    {
      return this.ReadADC(offsets, false);
    }

    public double[] ReadADC(short[] offsets, bool forceUpdate)
    {
      double[] numArray = new double[4];
      HIDData hidData = this.SendCalibrateADCCommand(offsets, forceUpdate);
      for (int index = 0; index < 4; ++index)
      {
        short amplitude = hidData.Stims[index].Amplitude;
        numArray[index] = (double) amplitude / 32768.0 * 5.0;
      }
      return numArray;
    }

    public byte SetPID(byte p, byte i, byte d)
    {
      return this.SetPID(p, i, d, (byte) 4);
    }

    public byte SetPID(byte p, byte i, byte d, byte chan_to_update)
    {
      return 0;
    }

    public byte SavePID()
    {
      return this.SendCommand(CM_5.CommandCodes.SavePidValues, (byte) 1);
    }

    public HIDData ReadPID()
    {
      this.Device.SendData(new HIDData((byte) 8));
      return CM5Device.ConvertData<HIDData>(this.Device.ReceiveData((byte) 8), 0);
    }

    private static void ListStims()
    {
      CM5Device dev = (CM5Device) null;
      foreach (CM_5 allCm5 in CM_5.AllCM5s)
      {
        try
        {
          allCm5.Device.Dispose();
        }
        catch
        {
        }
      }
      CM_5.AllCM5s.Clear();
      GC.Collect();
      GC.Collect();
      Thread.Sleep(100);
      bool flag = true;
      while (flag)
      {
        try
        {
          dev = new CM5Device(CM_5.DEVICE_USB_ID_VENDOR, CM_5.DEVICE_USB_ID_PID);
        }
        catch (Exception ex)
        {
          Thread.Sleep(1);
        }
        if (dev != null)
        {
          CM_5.AllCM5s.Add(new CM_5(dev));
          dev = (CM5Device) null;
          flag = true;
        }
        else
          flag = false;
        Thread.Sleep(100);
      }
    }

    private double[] FiniteVibration(List<HIDDataWrapper> data, bool EventsOn)
    {
      int num1 = (int) this.StopVibration();
      if (data.Count == 1)
      {
        if (EventsOn)
          this.TriggerStimulatorEvent(new StimulatorEventArgs()
          {
            EventType = StimulatorEventType.FiniteVibration,
            VibrationDuration = (double) data[0].Data.Duration / 1000.0
          });
        this.Device.SendData(data[0].Data);
        this.Vibrating = true;
        if ((int) this.Device.ReceiveData(data[0].Data.Command)[1] != (int) sbyte.MaxValue)
          return (double[]) null;
        if ((int) data[0].Data.TriggerChans > 0)
          this.waitingForTriggeredStimulus = -1;
        CM5Device.ConvertData<HIDData>(this.Device.ReceiveData(data[0].Data.Command), 0);
        this.Vibrating = false;
        return new double[1]{ 1.0 };
      }
      this.waitingForTriggeredStimulus = -2;
      int num2 = 0;
      foreach (HIDDataWrapper hidDataWrapper in data)
        num2 += (int) hidDataWrapper.Data.Duration;
      List<HIDDataWrapper> data1 = data;
      StimulatorEventArgs StartArgs;
      if (!EventsOn)
      {
        StartArgs = (StimulatorEventArgs) null;
      }
      else
      {
        StartArgs = new StimulatorEventArgs();
        StartArgs.EventType = StimulatorEventType.FiniteVibration;
        double num3 = (double) num2 / 1000.0;
        StartArgs.VibrationDuration = num3;
      }
      int num4 = this.LongVibration(data1, ref this.waitingForTriggeredStimulus, StartArgs);
      this.Vibrating = false;
      return new double[1]{ (double) num4 };
    }

    private int LongVibration(List<HIDDataWrapper> data, ref int ButtonPressed, StimulatorEventArgs StartArgs)
    {
      int num1 = this.SerialNumber == 0L ? 128 : 64;
      int index1 = data.Count > num1 ? num1 - 1 : data.Count - 1;
      if (index1 < num1 - 1 && (int) data[index1].Data.SubCommand > 0)
        return -1;
      for (int index2 = 0; index2 < index1; ++index2)
      {
        HIDDataWrapper hidDataWrapper = data[index2];
        this.Device.SendData(hidDataWrapper.Data);
        if ((int) this.Device.ReceiveData(hidDataWrapper.Data.Command)[1] > 126)
          return -1;
      }
      CM5Device device = this.Device;
      List<HIDDataWrapper> hidDataWrapperList = data;
      int index3 = index1;
      int num2 = 1;
      int num3 = index3 + num2;
      HIDData data1 = hidDataWrapperList[index3].Data;
      device.SendData(data1);
      if (StartArgs != null)
        this.TriggerStimulatorEvent(StartArgs);
      if ((int) this.Device.ReceiveData(data[0].Data.Command)[1] != (int) sbyte.MaxValue)
        return -1;
      this.Vibrating = true;
      int index4 = 0;
      int num4 = 0;
      ButtonPressed = -2;
      uint num5 = 0;
      while (ButtonPressed == -2 && this.Vibrating)
      {
        num4 = (int) data[index4].Data.Duration;
        byte[] Buffer = (int) data[index4].Data.TriggerChans <= 0 ? this.Device.ReceiveData((byte) 0) : this.Device.ReceiveData((byte) 0);
        if (ButtonPressed == -2)
        {
          VibRespData vibRespData = CM5Device.ConvertData<VibRespData>(Buffer, 0);
          if ((int) vibRespData.SubCommand >= 254)
          {
            num5 = vibRespData.SampleCounter;
            if (data[index4].EventArgs != null)
              this.TriggerStimulatorEvent(data[index4].EventArgs);
            ++index4;
            if ((int) vibRespData.SubCommand != (int) byte.MaxValue)
            {
              if (num3 < data.Count)
                this.Device.SendData(data[num3++].Data);
            }
            else
            {
              ButtonPressed = 1;
              num5 = vibRespData.SampleCounter;
            }
          }
          if (index4 == data.Count)
            ButtonPressed = int.MinValue;
        }
      }
      this.Vibrating = false;
      return (int) num5 / 4000;
    }

    private void SendCommandAsync(CM_5.CommandCodes command, byte SubCommand)
    {
      this.SendCommandAsync(new HIDData((byte) command, SubCommand));
    }

    private byte SendCommand(CM_5.CommandCodes command, byte SubCommand)
    {
      return this.SendCommand(new HIDData((byte) command, SubCommand));
    }

    private byte SendCommand(CM_5.CommandCodes command)
    {
      return this.SendCommand(new HIDData((byte) command));
    }

    private byte SendCommand(HIDData data)
    {
      this.Device.SendData(data);
      byte[] data1 = this.Device.ReceiveData(data.Command);
      CM5Device.ConvertData<ConfigData>(data1, 0);
      return data1[0];
    }

    private HIDData SendCalibrateADCCommand(short[] offsets, bool force)
    {
      HIDData data = new HIDData((byte) 7);
      for (int index = 0; index < offsets.Length; ++index)
      {
        if ((uint) offsets[index] > 0U | force)
          data.SubCommand = (byte) 1;
        data.Stims[index].Amplitude = offsets[index];
      }
      this.Device.SendData(data);
      return CM5Device.ConvertData<HIDData>(this.Device.ReceiveInputReport(), 1);
    }

    private ConfigData SendConfigCommand(CM_5.CommandCodes command, CM_5.SubCommandCodes subcommand)
    {
      return this.SendConfigCommand(new ConfigData()
      {
        Command = (byte) command,
        SubCommand = (byte) subcommand
      });
    }

    private ConfigData SendConfigCommand(ConfigData data)
    {
      this.Device.SendData(data);
      return CM5Device.ConvertData<ConfigData>(this.Device.ReceiveData(data.Command), 0);
    }

    private List<double> ReceiveAdcData(byte channel)
    {
      HIDData data = new HIDData((byte) 2, channel);
      this.Device.SendData(data);
      List<double> doubleList = new List<double>(10000);
      short num = -1;
      bool flag = true;
      while (flag)
      {
        AdcData adcData = CM5Device.ConvertData<AdcData>(this.Device.ReceiveData(data.Command), 0);
        flag = (int) adcData.SubCommand != 1;
        for (int index = 0; index < adcData.Data.Length; ++index)
          doubleList.Add((double) adcData.Data[index] / this.OpticalGains[(int) channel] * 2.0);
        if ((int) num < 0)
          num = adcData.StartingIndex;
        else if ((int) num != (int) adcData.StartingIndex)
          throw new InvalidDataException("Invalid ADC DATA");
      }
      return doubleList;
    }

    private void SendCommandAsync(HIDData data)
    {
      this.Device.SendData(data);
    }

    private static byte[] BitShift16(int x)
    {
      byte[] numArray = new byte[2]
      {
        (byte) 0,
        (byte) (x & (int) byte.MaxValue)
      };
      numArray[0] = (byte) (x >> 8 & (int) byte.MaxValue);
      return numArray;
    }

    private static byte[] BitShift32(int x)
    {
      byte[] numArray = new byte[4]
      {
        (byte) 0,
        (byte) 0,
        (byte) 0,
        (byte) (x & (int) byte.MaxValue)
      };
      numArray[2] = (byte) (x >> 8 & (int) byte.MaxValue);
      numArray[1] = (byte) (x >> 16 & (int) byte.MaxValue);
      numArray[0] = (byte) (x >> 24 & (int) byte.MaxValue);
      return numArray;
    }

    private static ushort ReverseShiftU16(byte[] arr, byte offset)
    {
      return (ushort) ((uint) arr[(int) offset] << 8 | (uint) arr[(int) offset + 1]);
    }

    public void RebootBootloader()
    {
      try
      {
        this.SendCommandAsync(CM_5.CommandCodes.RestartBootloader, (byte) 68);
      }
      catch
      {
      }
    }

    public ConfigData ReadConfigData()
    {
      HIDData data = new HIDData((byte) 12);
      this.Device.SendData(data);
      ConfigData configData = CM5Device.ConvertData<ConfigData>(this.Device.ReceiveData(data.Command), 0);
      if ((int) configData.Command < 128)
        return configData;
      throw new Exception("Failed to read config data");
    }

    private byte WriteOpticalGains(int multiplier, double ch1, double ch2, double ch3, double ch4)
    {
      ConfigData data = new ConfigData((byte) 13, (int) (ch1 * (double) multiplier), (int) (ch2 * (double) multiplier), (int) (ch3 * (double) multiplier), (int) (ch4 * (double) multiplier));
      this.Device.SendData(data);
      return this.Device.ReceiveData(data.Command)[0];
    }

    public byte WriteOpticalGains(double ch1, double ch2, double ch3, double ch4)
    {
      return this.WriteOpticalGains((int) this.ReadConfigData().Multiplier, ch1, ch2, ch3, ch4);
    }

    private ConfigData PowerUpRaw()
    {
      return this.SendConfigCommand(CM_5.CommandCodes.PowerUp, CM_5.SubCommandCodes.ContinueVibation);
    }

    public byte PowerUp()
    {
      ConfigData configData = this.PowerUpRaw();
      if ((int) configData.Command == (int) byte.MaxValue)
        throw new PowerUpException(string.Format("Power up Error Code: {0}", (object) configData.SubCommand));
      this.OpticalGains = new double[4];
      double multiplier = (double) configData.Multiplier;
      int num = 0;
      for (int index = 0; index < this.OpticalGains.Length; ++index)
      {
        this.OpticalGains[index] = (double) configData.OpticalGains[index] / multiplier;
        if (this.OpticalGains[index] != 1.0)
        {
          if (num < 2)
            this.LRIndexes[num++] = index;
          else
            ++num;
        }
      }
      this.TwoPointed = num == 2;
      this.SerialNumber = 0L;
      this.UnitType = "5";
      if (this.TwoPointed)
        this.UnitType = this.UnitType + ".2";
      this.UnitID = "CM5" + (object) this.SerialNumber;
      return configData.Command;
    }

    public byte PowerDown()
    {
      this.ControlMode = StimulatorControlMode.Force;
      return this.SendConfigCommand(CM_5.CommandCodes.PowerUp, CM_5.SubCommandCodes.FinishVibration).Command;
    }

    public uint StopVibration()
    {
      if (!this.Vibrating)
        return 0;
      if (this.waitingForTriggeredStimulus == -1)
      {
        this.waitingForTriggeredStimulus = 1;
        Thread.Sleep(1000);
      }
      this.Device.SendData(new HIDData((byte) 1));
      return 0;
    }

    public bool SetSerialNumber(int serialNumber)
    {
      ConfigData data = new ConfigData();
      return (int) this.SendConfigCommand(data).Command == (int) data.Command;
    }

    private enum CommandCodes : byte
    {
      Vibrate = 0,
      StopVibrate = 1,
      ReadAdc = 2,
      SetControlMode = 3,
      ReadSampleCounter = 4,
      WriteSerialNumber = 5,
      CalibrateVibration = 6,
      ReadSingleADC = 7,
      SavePidValues = 8,
      RestartBootloader = 9,
      PowerUp = 11,
      ReadConfig = 12,
      WriteConfig = 13,
    }

    private enum SubCommandCodes : byte
    {
      FinishVibration = 0,
      ForceMode = 0,
      PowerOff = 0,
      ContinueVibation = 1,
      PositionMode = 1,
      PowerOn = 1,
    }
  }
}
