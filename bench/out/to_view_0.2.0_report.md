# Benchmark - to_view

Benchmark run from 2020-01-17 19:15:08.455840Z UTC

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


__Input: empty__

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
    <td style="white-space: nowrap; text-align: right">76.48 M</td>
    <td style="white-space: nowrap; text-align: right">13.07 ns</td>
    <td style="white-space: nowrap; text-align: right">±28689.35%</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Mine</td>
    <td style="white-space: nowrap; text-align: right">74.43 M</td>
    <td style="white-space: nowrap; text-align: right">13.44 ns</td>
    <td style="white-space: nowrap; text-align: right">±24194.71%</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
    <td style="white-space: nowrap; text-align: right">6 ns</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap; text-align: right">68.92 M</td>
    <td style="white-space: nowrap; text-align: right">14.51 ns</td>
    <td style="white-space: nowrap; text-align: right">±24759.87%</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
    <td style="white-space: nowrap; text-align: right">126 ns</td>
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
    <td style="white-space: nowrap;text-align: right">76.48 M</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Mine</td>
    <td style="white-space: nowrap; text-align: right">74.43 M</td>
    <td style="white-space: nowrap; text-align: right">1.03x</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap; text-align: right">68.92 M</td>
    <td style="white-space: nowrap; text-align: right">1.11x</td>
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
    <td style="white-space: nowrap">40 B</td>
      <td>&nbsp;</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Mine</td>
    <td style="white-space: nowrap">40 B</td>
    <td>1.0x</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap">40 B</td>
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
    <td style="white-space: nowrap; text-align: right">27.45 M</td>
    <td style="white-space: nowrap; text-align: right">36.43 ns</td>
    <td style="white-space: nowrap; text-align: right">±13258.40%</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
    <td style="white-space: nowrap; text-align: right">556 ns</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity 1</td>
    <td style="white-space: nowrap; text-align: right">17.31 M</td>
    <td style="white-space: nowrap; text-align: right">57.78 ns</td>
    <td style="white-space: nowrap; text-align: right">±7814.67%</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
    <td style="white-space: nowrap; text-align: right">996 ns</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap; text-align: right">16.07 M</td>
    <td style="white-space: nowrap; text-align: right">62.22 ns</td>
    <td style="white-space: nowrap; text-align: right">±8013.65%</td>
    <td style="white-space: nowrap; text-align: right">0 ns</td>
    <td style="white-space: nowrap; text-align: right">669 ns</td>
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
    <td style="white-space: nowrap;text-align: right">27.45 M</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity 1</td>
    <td style="white-space: nowrap; text-align: right">17.31 M</td>
    <td style="white-space: nowrap; text-align: right">1.59x</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap; text-align: right">16.07 M</td>
    <td style="white-space: nowrap; text-align: right">1.71x</td>
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
    <td style="white-space: nowrap">136 B</td>
      <td>&nbsp;</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity 1</td>
    <td style="white-space: nowrap">136 B</td>
    <td>1.0x</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap">136 B</td>
    <td>1.0x</td>
  </tr>
</table>
<hr/>
