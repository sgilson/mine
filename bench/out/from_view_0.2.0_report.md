# Benchmark - from_view

Benchmark run from 2020-01-17 19:15:53.695741Z UTC

## System

Benchmark suite executing on the following system:

<table style="width: 1%">
  <tr>
    <th style="width: 1%; white-space: nowrap">Operating System</th>
    <td>Linux</td>
  </tr><tr>
    <th style="white-space: nowrap">CPU Information</th>
    <td style="white-space: nowrap">Intel(R) Core(TM) i7-6500U CPU @ 2.50GHz</td>
  </tr><tr>
    <th style="white-space: nowrap">Number of Available Cores</th>
    <td style="white-space: nowrap">4</td>
  </tr><tr>
    <th style="white-space: nowrap">Available Memory</th>
    <td style="white-space: nowrap">7.70 GB</td>
  </tr><tr>
    <th style="white-space: nowrap">Elixir Version</th>
    <td style="white-space: nowrap">1.9.4</td>
  </tr><tr>
    <th style="white-space: nowrap">Erlang Version</th>
    <td style="white-space: nowrap">22.2</td>
  </tr>
</table>

## Configuration

Benchmark suite executing with the following configuration:

<table style="width: 1%">
  <tr>
    <th style="width: 1%">:time</th>
    <td style="white-space: nowrap">2 s</td>
  </tr><tr>
    <th>:parallel</th>
    <td style="white-space: nowrap">1</td>
  </tr><tr>
    <th>:warmup</th>
    <td style="white-space: nowrap">2 s</td>
  </tr>
</table>

## Statistics


__Input: empty map__

Run Time
<table style="width: 1%">
  <tr>
    <th>Name</th>
    <th style="text-align: right">IPS</th>
    <th style="text-align: right">Average</th>
    <th style="text-align: right">Devitation</th>
    <th style="text-align: right">Median</th>
    <th style="text-align: right">99th&nbsp;%</th>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap; text-align: right">20.63 M</td>
    <td style="white-space: nowrap; text-align: right">48.47 ns</td>
    <td style="white-space: nowrap; text-align: right">±23011.81%</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
    <td style="white-space: nowrap; text-align: right">333.50 ns</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Mine</td>
    <td style="white-space: nowrap; text-align: right">19.02 M</td>
    <td style="white-space: nowrap; text-align: right">52.57 ns</td>
    <td style="white-space: nowrap; text-align: right">±33319.80%</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
    <td style="white-space: nowrap; text-align: right">170.50 ns</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity 1</td>
    <td style="white-space: nowrap; text-align: right">16.46 M</td>
    <td style="white-space: nowrap; text-align: right">60.74 ns</td>
    <td style="white-space: nowrap; text-align: right">±28104.70%</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
    <td style="white-space: nowrap; text-align: right">180.50 ns</td>
  </tr>
</table>
Comparison
<table style="width: 1%">
  <tr>
    <th>Name</th>
    <th style="text-align: right">IPS</th>
    <th style="text-align: right">Slower</th>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap;text-align: right">20.63 M</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Mine</td>
    <td style="white-space: nowrap; text-align: right">19.02 M</td>
    <td style="white-space: nowrap; text-align: right">1.08x</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity 1</td>
    <td style="white-space: nowrap; text-align: right">16.46 M</td>
    <td style="white-space: nowrap; text-align: right">1.25x</td>
  </tr>
</table>
Memory Usage
<table style="width: 1%">
  <tr>
    <th>Name</th>
    <th style="text-align: right">Memory</th>
      <th style="text-align: right">Factor</th>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap">48 B</td>
      <td>&nbsp;</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Mine</td>
    <td style="white-space: nowrap">48 B</td>
    <td>1.0x</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity 1</td>
    <td style="white-space: nowrap">48 B</td>
    <td>1.0x</td>
  </tr>
</table>
<hr/>

__Input: expected__

Run Time
<table style="width: 1%">
  <tr>
    <th>Name</th>
    <th style="text-align: right">IPS</th>
    <th style="text-align: right">Average</th>
    <th style="text-align: right">Devitation</th>
    <th style="text-align: right">Median</th>
    <th style="text-align: right">99th&nbsp;%</th>
  </tr>
  <tr>
    <td style="white-space: nowrap">Mine</td>
    <td style="white-space: nowrap; text-align: right">18.27 M</td>
    <td style="white-space: nowrap; text-align: right">54.74 ns</td>
    <td style="white-space: nowrap; text-align: right">±27935.78%</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
    <td style="white-space: nowrap; text-align: right">406.50 ns</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity 1</td>
    <td style="white-space: nowrap; text-align: right">16.55 M</td>
    <td style="white-space: nowrap; text-align: right">60.42 ns</td>
    <td style="white-space: nowrap; text-align: right">±22270.10%</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
    <td style="white-space: nowrap; text-align: right">268.50 ns</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap; text-align: right">10.22 M</td>
    <td style="white-space: nowrap; text-align: right">97.89 ns</td>
    <td style="white-space: nowrap; text-align: right">±12314.83%</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
    <td style="white-space: nowrap; text-align: right">588.50 ns</td>
  </tr>
</table>
Comparison
<table style="width: 1%">
  <tr>
    <th>Name</th>
    <th style="text-align: right">IPS</th>
    <th style="text-align: right">Slower</th>
  <tr>
    <td style="white-space: nowrap">Mine</td>
    <td style="white-space: nowrap;text-align: right">18.27 M</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity 1</td>
    <td style="white-space: nowrap; text-align: right">16.55 M</td>
    <td style="white-space: nowrap; text-align: right">1.1x</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap; text-align: right">10.22 M</td>
    <td style="white-space: nowrap; text-align: right">1.79x</td>
  </tr>
</table>
Memory Usage
<table style="width: 1%">
  <tr>
    <th>Name</th>
    <th style="text-align: right">Memory</th>
      <th style="text-align: right">Factor</th>
  </tr>
  <tr>
    <td style="white-space: nowrap">Mine</td>
    <td style="white-space: nowrap">48 B</td>
      <td>&nbsp;</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity 1</td>
    <td style="white-space: nowrap">48 B</td>
    <td>1.0x</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap">48 B</td>
    <td>1.0x</td>
  </tr>
</table>
<hr/>
