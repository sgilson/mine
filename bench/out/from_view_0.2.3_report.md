# Benchmark - from_view

Benchmark run from 2020-03-10 16:06:32.622146Z UTC

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
    <td style="white-space: nowrap">1.10.1</td>
  </tr><tr>
    <th style="white-space: nowrap">Erlang Version</th>
    <td style="white-space: nowrap">22.2.7</td>
  </tr>
</table>

## Configuration

Benchmark suite executing with the following configuration:

<table style="width: 1%">
  <tr>
    <th style="width: 1%">:time</th>
    <td style="white-space: nowrap">5 s</td>
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
    <td style="white-space: nowrap">Elixir - Functions with Arity 1</td>
    <td style="white-space: nowrap; text-align: right">11.19 M</td>
    <td style="white-space: nowrap; text-align: right">89.37 ns</td>
    <td style="white-space: nowrap; text-align: right">±51108.28%</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
    <td style="white-space: nowrap; text-align: right">168 ns</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap; text-align: right">10.76 M</td>
    <td style="white-space: nowrap; text-align: right">92.93 ns</td>
    <td style="white-space: nowrap; text-align: right">±55900.85%</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
    <td style="white-space: nowrap; text-align: right">175 ns</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Mine</td>
    <td style="white-space: nowrap; text-align: right">10.58 M</td>
    <td style="white-space: nowrap; text-align: right">94.51 ns</td>
    <td style="white-space: nowrap; text-align: right">±52634.76%</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
    <td style="white-space: nowrap; text-align: right">114 ns</td>
  </tr>
</table>
Comparison
<table style="width: 1%">
  <tr>
    <th>Name</th>
    <th style="text-align: right">IPS</th>
    <th style="text-align: right">Slower</th>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity 1</td>
    <td style="white-space: nowrap;text-align: right">11.19 M</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap; text-align: right">10.76 M</td>
    <td style="white-space: nowrap; text-align: right">1.04x</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Mine</td>
    <td style="white-space: nowrap; text-align: right">10.58 M</td>
    <td style="white-space: nowrap; text-align: right">1.06x</td>
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
    <td style="white-space: nowrap">Elixir - Functions with Arity 1</td>
    <td style="white-space: nowrap">48 B</td>
      <td>&nbsp;</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap">48 B</td>
    <td>1.0x</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Mine</td>
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
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap; text-align: right">11.48 M</td>
    <td style="white-space: nowrap; text-align: right">87.14 ns</td>
    <td style="white-space: nowrap; text-align: right">±47526.28%</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
    <td style="white-space: nowrap; text-align: right">95 ns</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity 1</td>
    <td style="white-space: nowrap; text-align: right">10.38 M</td>
    <td style="white-space: nowrap; text-align: right">96.38 ns</td>
    <td style="white-space: nowrap; text-align: right">±55692.71%</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
    <td style="white-space: nowrap; text-align: right">296 ns</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Mine</td>
    <td style="white-space: nowrap; text-align: right">9.23 M</td>
    <td style="white-space: nowrap; text-align: right">108.37 ns</td>
    <td style="white-space: nowrap; text-align: right">±41457.11%</td>
    <td style="white-space: nowrap; text-align: right">19 ns</td>
    <td style="white-space: nowrap; text-align: right">219 ns</td>
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
    <td style="white-space: nowrap;text-align: right">11.48 M</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity 1</td>
    <td style="white-space: nowrap; text-align: right">10.38 M</td>
    <td style="white-space: nowrap; text-align: right">1.11x</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Mine</td>
    <td style="white-space: nowrap; text-align: right">9.23 M</td>
    <td style="white-space: nowrap; text-align: right">1.24x</td>
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
    <td style="white-space: nowrap">Elixir - Functions with Arity 1</td>
    <td style="white-space: nowrap">48 B</td>
    <td>1.0x</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Mine</td>
    <td style="white-space: nowrap">48 B</td>
    <td>1.0x</td>
  </tr>
</table>
<hr/>
