using System;
using System.Collections.Generic;
using ThreadingTestLib;
using System.Threading;

namespace ThreadingTest
{
    internal class Program
    {
        public static void Main(string[] args)
        {
            Console.WriteLine("Hello");

            ExampleThread my_thread_object = new ExampleThread();
            Thread my_thread = new Thread(new ThreadStart(my_thread_object.Runner));

            my_thread.Start();

            Thread.Sleep(2000);
            my_thread_object.SendSignal();
            Thread.Sleep(2000);
            my_thread_object.SendSignal();
        }
    }
}