// Decompiled with JetBrains decompiler
// Type: CorticalMetrics.CM5Device
// Assembly: CM, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 4B58D3CC-37ED-4898-A21C-80094686906A
// Assembly location: F:\sbg\somatosensory_stim\CM.dll

using MadWizard.WinUSBNet;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Threading;

namespace CorticalMetrics
{
  internal class CM5Device
  {
    private Dictionary<int, Queue<byte[]>> ReceviedDatas = new Dictionary<int, Queue<byte[]>>();
    private int cancelPolling = -1;
    private USBDevice device;
    private USBInterface Interface;
    private Thread PollingThread;
    private bool _polling;

    public CM5Device(int vendorid, int productid)
    {
      this.device = USBDevice.GetSingleDevice("{6479AF78-C6D5-4053-8C7A-C58A513A7D60}");
      if (this.device == null)
      {
        foreach (USBDeviceInfo device in USBDevice.GetDevices("{a5dcbf10-6530-11d2-901f-00c04fb951ed}"))
        {
          if (device.PID == productid)
          {
            if (device.VID == vendorid)
            {
              try
              {
                this.device = new USBDevice(device);
                break;
              }
              catch
              {
              }
            }
          }
        }
      }
      if (this.device == null)
        throw new Exception("No Device Found");
      if (this.device.Descriptor.VID != vendorid || this.device.Descriptor.PID != productid)
      {
        this.device.Dispose();
        this.device = (USBDevice) null;
        throw new Exception("No Device Found");
      }
      this.Interface = this.device.Interfaces[0];
      this.StartPolling();
    }

    ~CM5Device()
    {
      if (this.device == null)
        return;
      this.StopPolling();
      this.device.Dispose();
    }

    public void Dispose()
    {
      this.StopPolling();
      this.device.Dispose();
      this.device = (USBDevice) null;
    }

    public void SendOutputReport(byte[] bytes, bool useControl)
    {
      this.Interface.OutPipe.Write(bytes);
    }

    public byte[] ReceiveInputReport()
    {
      byte[] numArray = new byte[this.Interface.InPipe.MaximumPacketSize];
      this.Interface.InPipe.Read(numArray);
      return numArray;
    }

    public byte[] ReceiveInputReport(int timeout)
    {
      int cancel = -1;
      return this.ReceiveInputReport(timeout, ref cancel);
    }

    public byte[] ReceiveInputReport(int timeout, ref int cancel)
    {
      byte[] numArray = new byte[64];
      IAsyncResult asyncResult = this.Interface.InPipe.BeginRead(numArray, 0, numArray.Length, (AsyncCallback) (res => {}), new object());
      if (timeout == -1)
      {
        while (cancel < 0)
        {
          if (asyncResult.IsCompleted)
            return numArray;
          Thread.Sleep(1);
        }
      }
      else
      {
        while (timeout-- > 0 && cancel < 0)
        {
          if (asyncResult.IsCompleted)
            return numArray;
          Thread.Sleep(1);
        }
      }
      this.Interface.InPipe.Abort();
      return (byte[]) null;
    }

    public void SendData(CM_BootLoader.Bootloader_Commands Command)
    {
      byte[] bytes = new byte[64];
      bytes[0] = (byte) Command;
      this.SendOutputReport(bytes, false);
    }

    public void SendData(GenericData data)
    {
      this.SendOutputReport(CM5Device.StructureToByteArray((object) data, 0), false);
    }

    public void SendData(HIDData data)
    {
      this.SendOutputReport(CM5Device.StructureToByteArray((object) data, 0), false);
    }

    public void SendData(ConfigData data)
    {
      this.SendOutputReport(CM5Device.StructureToByteArray((object) data, 0), false);
    }

    public byte[] _ReceiveData()
    {
      byte[] inputReport = this.ReceiveInputReport(10000, ref this.cancelPolling);
      if (inputReport == null)
        return (byte[]) null;
      byte[] numArray = new byte[inputReport.Length];
      for (int index = 0; index < inputReport.Length; ++index)
        numArray[index] = inputReport[index];
      return numArray;
    }

    public byte[] ReceiveData(byte command)
    {
      byte[] numArray = (byte[]) null;
      while (numArray == null)
      {
        if (this.ReceviedDatas.ContainsKey((int) command))
        {
          Queue<byte[]> receviedData = this.ReceviedDatas[(int) command];
          if (receviedData.Count > 0)
            numArray = receviedData.Dequeue();
        }
        Thread.Sleep(1);
      }
      return numArray;
    }

    public static T ConvertData<T>(byte[] Buffer, int remove)
    {
      remove = 0;
      byte[] numArray = new byte[Buffer.Length - remove];
      for (int index = remove; index < Buffer.Length; ++index)
        numArray[index - remove] = Buffer[index];
      GCHandle gcHandle = GCHandle.Alloc((object) numArray, GCHandleType.Pinned);
      object structure = Marshal.PtrToStructure(gcHandle.AddrOfPinnedObject(), typeof (T));
      gcHandle.Free();
      return (T) structure;
    }

    public static byte[] StructureToByteArray(object obj, int prependLength)
    {
      int num1 = Marshal.SizeOf(obj);
      byte[] destination = new byte[num1 + prependLength];
      IntPtr num2 = Marshal.AllocHGlobal(num1);
      Marshal.StructureToPtr(obj, num2, true);
      Marshal.Copy(num2, destination, prependLength, num1);
      Marshal.FreeHGlobal(num2);
      return destination;
    }

    private void StartPolling()
    {
      if (this.PollingThread != null)
        return;
      this.PollingThread = new Thread((ThreadStart) (() =>
      {
        this._polling = true;
        this.cancelPolling = -1;
        while (this._polling)
        {
          byte[] data = this._ReceiveData();
          if (data != null)
          {
            int key = (int) data[0] & (int) sbyte.MaxValue;
            if (!this.ReceviedDatas.ContainsKey(key))
              this.ReceviedDatas.Add(key, new Queue<byte[]>());
            if (this.ReceviedDatas[key].Count < 100 && key != 7)
              this.ReceviedDatas[key].Enqueue(data);
          }
          Thread.Sleep(1);
        }
      }));
      this.PollingThread.Start();
    }

    private void StopPolling()
    {
      this._polling = false;
      this.cancelPolling = 1;
      if (this.PollingThread != null)
        this.PollingThread.Join();
      this.PollingThread = (Thread) null;
      this.Interface.InPipe.Flush();
    }
  }
}
