# Mine

[![Hex Version](https://img.shields.io/hexpm/v/mine.svg)](https://hex.pm/packages/mine) 
[![Documentation](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/mine/) 
[![Build Status Travis](https://travis-ci.com/sgilson/mine.svg?branch=master)](https://travis-ci.com/sgilson/mine) 
[![Coverage Status](https://coveralls.io/repos/github/sgilson/mine/badge.svg?branch=master)](https://coveralls.io/github/sgilson/mine?branch=master)

Mine is a lightweight package for defining views for structs. It
aims to eliminate the boilerplate required to write and maintain an 
anti-corruption layer between your structs and any external APIs you
interface with.

**Note:** Mine currently exports the minimum functionality required for my own use case 
but is not ready for adoption yet. Until v1.0.0, the interface may change in ways that break 
backwards compatibility.

## Usage

### Basic Views

```elixir
defmodule User do
  use Mine

  # module must declare a struct
  defstruct [:name, :email, :password]
  
  defview do
    alias_field :name, as: "userName", default: "John Doe"
    ignore_field :password
  end
end
```

A view is created by importing `Mine` at the beginning of your module and using
the exported `defview/2` macro. Note that `User` declares a struct and the `defview`
is used after the declaration. This requirement stems from the intent of `Mine`
to be purely additive. It will not replace functionality provided by more mature
modules but rather build on existing code. The most notable benefit to this approach
is that other packages that internally define structs (like Ecto) can be extended.

At compile time, `Mine` will create views for every module in use. Any
incompatibilities between the declared views and their base structs will be caught here,
providing the benefit of runtime safety. To access the compiled view at runtime,
the following methods will be found on your module.

- `to_view/2`: Covert struct to a map for a given view
- `from_view/2`: Convert source map to struct. Convenience 
method for normalizing an input map, using it to create a struct, and validating the
result. Relies on the above methods to accomplish this.

These functions should ideally be used between your serialization layer and business logic.

More info on these functions can be found on HexDocs.

### Available Macros

There are several macros that can be used inside the scope of `defview`. They are:

- `alias_field/2`: Change the key for a given field. Has the following uses:
     - `alias_field(:key, "as")` View will use `"as"` instead of the field name `:key`
     - `alias_field(:key, as: "as", default: "def")` Same as above, but if `:key` is
     not found or it's value is `nil`, `"def"` will be used as the value instead.
- `ignore_field/1`: Field will be ignored in both `to_view` and from `from_view`.
- `add_field/2`: A key value pair that will be added to any map produced by `to_view`.
Ignored in `from_view`.

### Named Views

In some cases, it may not be enough to have a single exported view of a struct.
To support this use case, every view created by `Mine` has a name (with `:default`)
being the default. The additional functions `to_view/1` and `from_view/1` work with 
the default view name.

A more complicated `User` module may declare views such as these:

```elixir
...

# functions with arity 1 will use this view
default_view :front_end

# other fields will remain untouched
defview :third_party_api do
  alias_field :name, as: "userName"
end

defview :front_end do
  alias_field :name, default: "?"
  alias_field :email, default: "unknown"
  ignore_field :password
end

...
```

## Rationale

While interfacing with an external API written in Java, I frequently ran across 
instances in which I would need to map a struct's key, ignore certain fields, 
or add constant fields to outgoing requests. The process of setting up these mappings
is tiresome and potentially error prone.

Let's take the most extreme example I encountered. This is the required JSON format
for a port in an unnamed API:

```json
{
  "$": 7000,
  "@enabled": false
}
```

Peculiar formats such as this were littered throughout the API, leading to several
modules with structures similar to the following:

```elixir
defmodule PortV1 do
  defstruct [:num, :enabled]

  def to_view(%PortV1{num: num, enabled: enabled}) do
    %{
      "$" => num,
      "@enabled" => enabled
    }
  end

  def from_view(%{"$" => num, "@enabled" => enabled}) do
    %PortV1{num: num, enabled: enabled}
  end
end
```

Code like this:

- is necessary to maintain a clean internal structure
- adds more noise than meaning
- can be error prone

Given these conditions, I opted to break my first rule of writing macros in Elixir
(avoid it). Instead of the example seen above, using `mine` allows for a much more
concise representation of a mapping to the external world.

```elixir
defmodule PortV2 do
  use Mine
  defstruct [:num, :enabled]

  defview do
    alias_field :num, "$"
    alias_field :enabled, "@enabled"
  end
end
```

This representation is easier to read, maintain, and is even checked for validity 
at compile time. In addition, the generated code is nearly identical to the 
code written by hand, resulting in a minimal performance impact.

## Installation

Mine can be installed by adding `mine` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mine, "~> 0.2.0"}
  ]
end
```

## Benchmarking

To benchmark the generated functions against those written by hand, run the 
following:

```shell script
MIX_ENV=bench mix run bench/run.exs
```

## Roadmap

If this project gathers any interest, here are some steps I would like to take
to improve the library:

- [ ] Compare mapping strategies to determine the fastest approach
- [ ] Additional options for when to use default values
- [ ] `embedded_view key, module` macro: signals that the contents of the target 
field is also a struct using `Mine` and should be translated accordingly in `to_view` and
`from_view`
- [ ] Ecto integration: when a given module is using Ecto, `validate` will automatically 
use the `changeset/1` function for validation
- [ ] Phoenix integration via Plug: simple plug to map request/response bodies
to their intended form after parsing
