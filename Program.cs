using Serilog;
using System;
using System.Timers;

namespace LogsTesting
{
	class Program
	{
		static void Main(string[] args)
		{
			Log.Logger = new LoggerConfiguration()
				.MinimumLevel.Information()
				.WriteTo.Console(standardErrorFromLevel: Serilog.Events.LogEventLevel.Error)
				.CreateLogger();

			var index = 0L;
			var timer = new Timer(3000);
			timer.Elapsed += (args, e) =>
			{
				if (index % 2 == 0)
					Log.Information("Information message from LogsTesting {index}", ++index);
				else
					Log.Error("Error message from LogsTesting {index}", ++index);
			};
			timer.Start();
			while (true);
		}
	}
}
