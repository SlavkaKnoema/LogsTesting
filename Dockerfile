#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/runtime:5.0 AS base

RUN apt-get -y update
RUN apt-get -y install curl

ENV DD_AGENT_MAJOR_VERSION=7 \
 DD_SITE=datadoghq.com \
 CORECLR_ENABLE_PROFILING=1 \
 CORECLR_PROFILER={846F5F1C-F9AE-4B07-969E-05C26BC060D8} \
 CORECLR_PROFILER_PATH=/opt/datadog/Datadog.Trace.ClrProfiler.Native.so \
 DD_INTEGRATIONS=/opt/datadog/integrations.json \
 DD_DOTNET_TRACER_HOME=/opt/datadog \
 DD_LOGS_INJECTION=true \
 DD_TRACE_SAMPLE_RATE=1 \
 DD_TRACE_ENABLED=true \
 DD_RUNTIME_METRICS_ENABLED=true 

RUN mkdir -p /opt/datadog
RUN curl -L https://github.com/DataDog/dd-trace-dotnet/releases/download/v1.25.0/datadog-dotnet-apm_1.25.0_amd64.deb --output /opt/datadog/datadog.deb
RUN dpkg -i /opt/datadog/datadog.deb
RUN chmod u+x /opt/datadog/createLogPath.sh && /opt/datadog/createLogPath.sh
RUN rm /opt/datadog/datadog.deb

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish "LogsTesting.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish ./
ENTRYPOINT ["dotnet", "LogsTesting.dll"]