# Benchmark - to_view

Benchmark run from 2020-03-10 16:05:15.048591Z UTC

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
    <td style="white-space: nowrap; text-align: right">18.46 M</td>
    <td style="white-space: nowrap; text-align: right">54.16 ns</td>
    <td style="white-space: nowrap; text-align: right">±18333.91%</td>
    <td style="white-space: nowrap; text-align: right">17 ns</td>
    <td style="white-space: nowrap; text-align: right">170 ns</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Mine</td>
    <td style="white-space: nowrap; text-align: right">12.43 M</td>
    <td style="white-space: nowrap; text-align: right">80.47 ns</td>
    <td style="white-space: nowrap; text-align: right">±19567.90%</td>
    <td style="white-space: nowrap; text-align: right">35 ns</td>
    <td style="white-space: nowrap; text-align: right">317 ns</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap; text-align: right">10.56 M</td>
    <td style="white-space: nowrap; text-align: right">94.69 ns</td>
    <td style="white-space: nowrap; text-align: right">±17261.83%</td>
    <td style="white-space: nowrap; text-align: right">58 ns</td>
    <td style="white-space: nowrap; text-align: right">398 ns</td>
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
    <td style="white-space: nowrap;text-align: right">18.46 M</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Mine</td>
    <td style="white-space: nowrap; text-align: right">12.43 M</td>
    <td style="white-space: nowrap; text-align: right">1.49x</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap; text-align: right">10.56 M</td>
    <td style="white-space: nowrap; text-align: right">1.75x</td>
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
    <td style="white-space: nowrap; text-align: right">3.94 M</td>
    <td style="white-space: nowrap; text-align: right">253.98 ns</td>
    <td style="white-space: nowrap; text-align: right">±8388.92%</td>
    <td style="white-space: nowrap; text-align: right">213 ns</td>
    <td style="white-space: nowrap; text-align: right">403 ns</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity 1</td>
    <td style="white-space: nowrap; text-align: right">2.90 M</td>
    <td style="white-space: nowrap; text-align: right">344.94 ns</td>
    <td style="white-space: nowrap; text-align: right">±7796.64%</td>
    <td style="white-space: nowrap; text-align: right">272 ns</td>
    <td style="white-space: nowrap; text-align: right">981 ns</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap; text-align: right">2.68 M</td>
    <td style="white-space: nowrap; text-align: right">373.64 ns</td>
    <td style="white-space: nowrap; text-align: right">±7120.25%</td>
    <td style="white-space: nowrap; text-align: right">296 ns</td>
    <td style="white-space: nowrap; text-align: right">928 ns</td>
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
    <td style="white-space: nowrap;text-align: right">3.94 M</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity 1</td>
    <td style="white-space: nowrap; text-align: right">2.90 M</td>
    <td style="white-space: nowrap; text-align: right">1.36x</td>
  </tr>
  <tr>
    <td style="white-space: nowrap">Elixir - Functions with Arity >1</td>
    <td style="white-space: nowrap; text-align: right">2.68 M</td>
    <td style="white-space: nowrap; text-align: right">1.47x</td>
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
