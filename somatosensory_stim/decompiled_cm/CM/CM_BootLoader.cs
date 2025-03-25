// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.CM_BootLoader
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using System;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;

namespace CorticalMetrics
{
  internal class CM_BootLoader : INotifyPropertyChanged
  {
    private CM5Device device;
    private string _ActionName;
    private double _Progress;

    public string ActionName
    {
      get
      {
        return this._ActionName;
      }
      protected set
      {
        this._ActionName = value;
        this.OnPropertyChanged("ActionName");
      }
    }

    public double Progress
    {
      get
      {
        return this._Progress;
      }
      protected set
      {
        this._Progress = value;
        this.OnPropertyChanged("Progress");
      }
    }

    public event PropertyChangedEventHandler PropertyChanged;

    internal CM_BootLoader(CM5Device dev)
    {
      this.device = dev;
    }

    private void _write_verify_hex(string[] lines, int verify)
    {
      uint num1 = 0;
      uint num2 = 0;
      uint addrSave = 0;
      byte buffLen = 0;
      byte[] bytes = new byte[56];
      double length = (double) lines.Length;
      double num3 = 0.0;
      foreach (string line in lines)
      {
        this.Progress = num3++ / length;
        uint uint32_1 = Convert.ToUInt32(line.Substring(1, 2), 16);
        uint uint32_2 = Convert.ToUInt32(line.Substring(3, 4), 16);
        uint uint32_3 = Convert.ToUInt32(line.Substring(7, 2), 16);
        int startIndex = 9 + (int) uint32_1 * 2;
        byte[] numArray = CM_BootLoader.atoh(line.Substring(9, (int) uint32_1 * 2));
        int int32 = Convert.ToInt32(line.Substring(startIndex, 2), 16);
        int num4 = 0;
        foreach (int num5 in CM_BootLoader.atoh(line.Substring(1, 8)))
          num4 = num4 + (256 - num5) & (int) byte.MaxValue;
        for (int index = 0; index < numArray.Length; ++index)
          num4 = num4 + (256 - (int) numArray[index]) & (int) byte.MaxValue;
        if (int32 != num4)
          throw new Exception("Checksum failed");
        if ((int) uint32_3 == 0)
        {
          if ((int) num1 + (int) uint32_2 != (int) num2)
          {
            num2 = num1 + uint32_2;
            if ((int) buffLen > 0)
            {
              this.issueBlock(addrSave, buffLen, verify, bytes);
              buffLen = (byte) 0;
            }
            addrSave = num2;
          }
          for (int index = 0; index < numArray.Length; ++index)
          {
            bytes[(int) buffLen++] = numArray[index];
            if ((int) buffLen == bytes.Length)
            {
              this.issueBlock(addrSave, buffLen, verify, bytes);
              buffLen = (byte) 0;
            }
            if (-1 == (int) num2)
            {
              if ((int) buffLen > 0)
              {
                this.issueBlock(addrSave, buffLen, verify, bytes);
                buffLen = (byte) 0;
              }
              num2 = 0U;
            }
            else
              ++num2;
            if ((int) buffLen == 0)
              addrSave = num2;
          }
        }
        else if ((int) uint32_3 != 1)
        {
          if ((int) uint32_3 == 4)
          {
            num1 = Convert.ToUInt32(line.Substring(9, 4), 16) << 16;
            num2 = num1 + uint32_2;
            if ((int) buffLen > 0)
            {
              this.issueBlock(addrSave, buffLen, verify, bytes);
              buffLen = (byte) 0;
              addrSave = num2;
            }
          }
        }
        else
          break;
      }
      if ((int) buffLen > 0)
        this.issueBlock(addrSave, buffLen, verify, bytes);
      if ((int) buffLen != 56)
        return;
      this.device.SendData(CM_BootLoader.Bootloader_Commands.PROGRAM_COMPLETE);
    }

    public void WriteHex(string[] lines, bool reset)
    {
      this.query_device();
      this.ActionName = "Erasing";
      this.Erase();
      this.ActionName = "Writing";
      Stopwatch stopwatch = new Stopwatch();
      stopwatch.Start();
      this._write_verify_hex(lines, 0);
      stopwatch.Stop();
      this.ActionName = "Verifying";
      stopwatch.Reset();
      stopwatch.Start();
      this._write_verify_hex(lines, 1);
      stopwatch.Stop();
      if (!reset)
        return;
      this.Reset();
    }

    public void WriteHex(string filename, bool reset)
    {
      if (!File.Exists(filename))
        throw new FileNotFoundException("Couldnt find hex file");
      string[] lines = File.ReadAllLines(filename);
      if (lines == null)
        throw new FileLoadException("Couldn't load file");
      this.WriteHex(lines, reset);
    }

    private void issueBlock(uint addrSave, byte buffLen, int verify, byte[] bytes)
    {
      GenericData data = new GenericData();
      data.Address = addrSave;
      data.Size = buffLen;
      data.Data = new byte[56];
      int num = data.Data.Length - (int) buffLen;
      for (int index = 0; index < (int) buffLen; ++index)
        data.Data[num + index] = bytes[index];
      if (verify == 0)
      {
        data.Command = (byte) 5;
        this.device.SendData(data);
        if ((int) buffLen >= 56)
          return;
        this.device.SendData(CM_BootLoader.Bootloader_Commands.PROGRAM_COMPLETE);
      }
      else
      {
        data.Command = (byte) 7;
        this.device.SendData(data);
        GenericData genericData = CM5Device.ConvertData<GenericData>(this.device.ReceiveData(data.Command), 0);
        for (int index = 0; index < data.Data.Length; ++index)
        {
          if ((int) genericData.Data[index] != (int) data.Data[index])
            throw new InvalidDataException("Did not verify");
        }
      }
    }

    private static byte[] atoh(string s)
    {
      if (s.Length % 2 != 0)
        throw new Exception("Error with uneven number of chars");
      byte[] numArray = new byte[s.Length / 2];
      int startIndex = 0;
      while (startIndex < s.Length)
      {
        numArray[startIndex / 2] = (byte) Convert.ToInt32(s.Substring(startIndex, 2), 16);
        startIndex += 2;
      }
      return numArray;
    }

    private QueryData query_device()
    {
      this.device.SendData(CM_BootLoader.Bootloader_Commands.QUERY_DEVICE);
      return CM5Device.ConvertData<QueryData>(this.device.ReceiveData((byte) 2), 0);
    }

    private void Erase()
    {
      this.device.SendData(CM_BootLoader.Bootloader_Commands.ERASE_DEVICE);
      this.device.SendData(CM_BootLoader.Bootloader_Commands.QUERY_DEVICE);
      this.device.ReceiveInputReport(30000);
    }

    public void Reset()
    {
      this.device.SendData(CM_BootLoader.Bootloader_Commands.RESET_DEVICE);
    }

    protected virtual void OnPropertyChanged(string propertyName)
    {
      // ISSUE: reference to a compiler-generated field
      if (this.PropertyChanged == null)
        return;
      // ISSUE: reference to a compiler-generated field
      this.PropertyChanged((object) this, new PropertyChangedEventArgs(propertyName));
    }

    internal enum Bootloader_Commands
    {
      QUERY_DEVICE = 2,
      UNLOCK_CONFIG = 3,
      ERASE_DEVICE = 4,
      PROGRAM_DEVICE = 5,
      PROGRAM_COMPLETE = 6,
      GET_DATA = 7,
      RESET_DEVICE = 8,
    }

    private enum ERASE_DEVICE_Commands
    {
      UNLOCKCONFIG,
      LOCKCONFIG,
    }

    private enum QUERY_DEVICE_Commands
    {
      TypeProgramMemory = 1,
      TypeEEPROM = 2,
      TypeConfigWords = 3,
      TypeEndOfTypeList = 255,
    }

    private enum ErrorCode
    {
      ERR_NONE,
      ERR_CMD_ARG,
      ERR_CMD_UNKNOWN,
      ERR_UBW32_NOT_FOUND,
      ERR_USB_INIT1,
      ERR_USB_INIT2,
      ERR_USB_OPEN,
      ERR_USB_WRITE,
      ERR_USB_READ,
      ERR_HEX_OPEN,
      ERR_HEX_STAT,
      ERR_HEX_MMAP,
      ERR_HEX_SYNTAX,
      ERR_HEX_CHECKSUM,
      ERR_HEX_RECORD,
      ERR_VERIFY,
      ERR_EOL,
    }
  }
}
