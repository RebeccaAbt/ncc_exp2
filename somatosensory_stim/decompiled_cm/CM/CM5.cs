// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.CM5
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System;
using System.Collections.Generic;
using System.Threading;

namespace CorticalMetrics
{
  public class CM5
  {
    private CM_5 wrappedDevice;

    public bool UseOutputTriggers { get; set; }

    public bool UseInputTrigger { get; set; }

    public StimulatorControlMode ControlMode
    {
      get
      {
        return this.wrappedDevice.ControlMode;
      }
      set
      {
        this.wrappedDevice.ControlMode = value;
      }
    }

    public event StimulatorEventHandler StimulatorEvent;

    private CM5(CM_5 device)
    {
      this.wrappedDevice = device;
      if (this.wrappedDevice == null)
        throw new StimNotFound("No Device Found");
      this.wrappedDevice.StimulatorEvent += new StimulatorEventHandler(this.wrappedDevice_StimulatorEvent);
    }

    public CM5()
      : this(CM_5.CreateStim())
    {
    }

    ~CM5()
    {
      try
      {
        this.wrappedDevice.Deinitialize();
        this.wrappedDevice.CleanUpTasks();
      }
      catch (Exception ex)
      {
      }
      finally
      {
        // ISSUE: explicit finalizer call
        //base.Finalize();
      }
    }

    private void wrappedDevice_StimulatorEvent(object sender, StimulatorEventArgs e)
    {
      // ISSUE: reference to a compiler-generated field
      if (this.StimulatorEvent == null)
        return;
      // ISSUE: reference to a compiler-generated field
      this.StimulatorEvent(sender, e);
    }

    public static CM5[] AllStims()
    {
      List<CM5> cm5List = new List<CM5>(2);
      foreach (CM_5 allStim in CM_5.CreateAllStims())
        cm5List.Add(new CM5(allStim));
      return cm5List.ToArray();
    }

    public void Init()
    {
      this.wrappedDevice.Initialize();
    }

    public void Init(bool inForceMode)
    {
      this.wrappedDevice.Initialize(inForceMode);
    }

    public void DeInit()
    {
      int num = (int) this.wrappedDevice.StopVibration();
      this.wrappedDevice.Deinitialize();
    }

    public void CleanUp()
    {
      this.wrappedDevice.CleanUpTasks();
    }

    public void StopVibration()
    {
      int num = (int) this.wrappedDevice.StopVibration();
    }

    public void SimpleVibration(Stimulus CH1, Stimulus CH2, Stimulus CH3, Stimulus CH4)
    {
      this.ChainedVibration(new QuadStimulusChain()
      {
        CH1 = {
          new StimulusLink(CH1)
        },
        CH2 = {
          new StimulusLink(CH2)
        },
        CH3 = {
          new StimulusLink(CH3)
        },
        CH4 = {
          new StimulusLink(CH4)
        }
      });
    }

    public void ChainedVibration(QuadStimulusChain chain)
    {
      try
      {
        this.wrappedDevice.ChainVibration(chain, true, this.UseInputTrigger, this.UseOutputTriggers);
      }
      catch (Exception ex)
      {
      }
    }

    public int Version()
    {
      return 11;
    }

    public static List<StimulusLink> GenerateAperiodicStimulus(double amplitude, double frequency, double duration)
    {
      if (frequency > 49.0)
        throw new ArgumentOutOfRangeException("Frequency must be < 50hz");
      return Stimulator.GenerateRomoChain(new Stimulus(amplitude, frequency, duration));
    }

    public void SetPID(PID pid)
    {
      this.SetPID(pid.P, pid.I, pid.D);
    }

    public void SetPID(PID pid, byte chan)
    {
      this.SetPID(pid.P, pid.I, pid.D, chan);
    }

    public void SetPID(byte p, byte i, byte d)
    {
      int num = (int) this.wrappedDevice.SetPID(p, i, d);
    }

    public void SetPID(byte p, byte i, byte d, byte chan)
    {
      int num = (int) this.wrappedDevice.SetPID(p, i, d, chan);
    }

    public PID[] GetPID()
    {
      this.wrappedDevice.ReadPID();
      return new PID[4]
      {
        new PID(),
        new PID(),
        new PID(),
        new PID()
      };
    }

    public void SavePID()
    {
      int num = (int) this.wrappedDevice.SavePID();
    }

    private void UpdateFirmware(string[] linesFromHexFile)
    {
      this.wrappedDevice.RebootBootloader();
      Thread.Sleep(3000);
      CM_BootLoader bootloaderStim = CM_5.CreateBootloaderStim();
      if (bootloaderStim == null)
        throw new StimNotFound("Bootloader not found");
      bootloaderStim.WriteHex(linesFromHexFile, true);
    }
  }
}
