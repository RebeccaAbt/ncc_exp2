// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.Stimulus
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System.ComponentModel;

namespace CorticalMetrics
{
  public class Stimulus : INotifyPropertyChanged
  {
    private double _amplitude;
    private double _frequency;
    private double _duration;
    private double _phase;
    private double _indent;
    private double _indentToStim;
    private double _startTemp;
    private double _diameter;
    private string _shape;

    public double Amplitude
    {
      get
      {
        return this._amplitude;
      }
      set
      {
        this._amplitude = value;
        this.OnPropertyChanged("Amplitude");
      }
    }

    public double Frequency
    {
      get
      {
        return this._frequency;
      }
      set
      {
        this._frequency = value;
        this.OnPropertyChanged("Frequency");
      }
    }

    public double Duration
    {
      get
      {
        return this._duration;
      }
      set
      {
        this._duration = value;
        this.OnPropertyChanged("Duration");
      }
    }

    public double Phase
    {
      get
      {
        return this._phase;
      }
      set
      {
        this._phase = value;
        this.OnPropertyChanged("Phase");
      }
    }

    public double Indent
    {
      get
      {
        return this._indent;
      }
      set
      {
        this._indent = value;
        this.OnPropertyChanged("Indent");
      }
    }

    public double IndentToStim
    {
      get
      {
        return this._indentToStim;
      }
      set
      {
        this._indentToStim = value;
        this.OnPropertyChanged("IndentToStim");
      }
    }

    public double StartTemp
    {
      get
      {
        return this._startTemp;
      }
      set
      {
        this._startTemp = value;
        this.OnPropertyChanged("StartTemp");
      }
    }

    public double Diameter
    {
      get
      {
        return this._diameter;
      }
      set
      {
        this._diameter = value;
        this.OnPropertyChanged("Diameter");
      }
    }

    public string Shape
    {
      get
      {
        return this._shape;
      }
      set
      {
        this._shape = value;
        this.OnPropertyChanged("Shape");
      }
    }

    public event PropertyChangedEventHandler PropertyChanged;

    public Stimulus()
    {
    }

    public Stimulus(double amp, double freq, double dur)
      : this(amp, freq, dur, 0.0)
    {
    }

    internal Stimulus(double amp, double freq, double dur, double ind)
    {
      this.Amplitude = amp;
      this.Frequency = freq;
      this.Duration = dur;
      this.Phase = 0.0;
      this.Indent = ind;
      this.IndentToStim = 0.0;
      this.StartTemp = 0.0;
      this.Diameter = 3.0;
      this.Shape = "Circular";
    }

    public Stimulus(double dur)
      : this(0.0, 10.0, dur, 0.0)
    {
    }

    public Stimulus Clone()
    {
      return new Stimulus()
      {
        Amplitude = this.Amplitude,
        Diameter = this.Diameter,
        Duration = this.Duration,
        Frequency = this.Frequency,
        Indent = this.Indent,
        IndentToStim = this.IndentToStim,
        Phase = this.Phase,
        Shape = this.Shape,
        StartTemp = this.StartTemp
      };
    }

    public Stimulus CloneUMtoMM()
    {
      return new Stimulus()
      {
        Amplitude = this.Amplitude / 1000.0,
        Diameter = this.Diameter,
        Duration = this.Duration,
        Frequency = this.Frequency,
        Indent = this.Indent,
        IndentToStim = this.IndentToStim,
        Phase = this.Phase,
        Shape = this.Shape,
        StartTemp = this.StartTemp
      };
    }

    protected virtual void OnPropertyChanged(string propertyName)
    {
      // ISSUE: reference to a compiler-generated field
      if (this.PropertyChanged == null)
        return;
      // ISSUE: reference to a compiler-generated field
      this.PropertyChanged((object) this, new PropertyChangedEventArgs(propertyName));
    }
  }
}
