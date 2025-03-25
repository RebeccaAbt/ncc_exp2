using System;
using System.Threading;

namespace ThreadingTestLib
{
    public class ExampleThread
    {
        private EventWaitHandle ewh;

        public ExampleThread()
        {
            this.ewh = new EventWaitHandle(false, EventResetMode.AutoReset);
        }

        public void SendSignal()
        {
            this.ewh.Set();
        }

        public void Runner()
        {
            Console.WriteLine("Hello from the Thread");

            while (true)
            {
                Console.WriteLine("Thread is waiting...");
                this.ewh.WaitOne();
                Console.WriteLine("Got a signal");
            }
        }
    }
}