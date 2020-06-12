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
    field :name, as: "userName", default: ""
    ignore :password
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
   ```elixir
   User.to_view(%User{name: "Bob", email: "abc@d.com", password: "secret"}, :default)
   # %{"userName" => "Bob", "email" => "abc@d.com"}
   ```
- `from_view/2`: Convert source map to struct
  ```elixir
  User.from_view(%{"email" => "abc@d.com", "password" => "shouldn't be here"}, :default)
  # %User{name: "", email: "abc@d.com", password: nil}
  ```

The first argument for both of these functions is the data to translate. The second is the name of the view to use 
for this translation. A module using Mine can have multiple views to capture the formatting requirements of 
different domains. In this case, `:default` was not needed, since the second parameter defaults to this value 
unless configured otherwise.

These functions should ideally be used between your serialization layer and business logic. For example,
after retrieving data from a third party API, your application would deserialiaze the data using 
[devinus/poison](https://github.com/devinus/poison) or [michalmuskala/jason](https://github.com/michalmuskala/jason),
pass the resulting map through Mine, and then validate the results using an 
[Ecto changeset](https://hexdocs.pm/ecto/Ecto.Changeset.html#content) before persisting the data.

More info on these functions can be found on HexDocs.

### Available Macros

There are several macros that can be used inside the scope of `defview`. They are:

- `field/2`: Change the key for a given field. Has the following uses:
     - `field(:key, "as")` View will use `"as"` instead of the field name `:key`
     - `field(:key, default: "def")` Same as above, but if `:key` is
     not found or it's value is `nil`, `"def"` will be used as the value instead.
     - `field(:key, map_to: &String.upcase/1)` When using `to_view`,
     value of field in struct will be accessed, mapped using `map_to`, and stored 
     under the key `"as"` in the resulting map
     - `field(:key, map_from: &String.downcase/1)` When using 
     `from_view`, value of `"as"` in the given map will be fetched and passed
     as the only argument to the function in `map_from`.
- `ignore/1`: Field will be ignored in both `to_view` and from `from_view`.
- `append/2`: A key value pair that will be added to any map produced by `to_view`.
Ignored in `from_view`.

### Named Views

In some cases, it may not be enough to have a single exported view of a struct.
To support this use case, every view created by `Mine` has a name. `:default` will
be used when a name is not provided.

`default_view/1` changes which view is used for the single arity versions of 
`to_view` and `from_view`.

A more complicated `User` module may look something like this:

```elixir
...

# to_veiw/1 and from_view/1 will use this view
# instead of :default
default_view :front_end

# other fields will remain untouched
defview :third_party_api do
  field :name, as: "userName"
end

defview :front_end do
  field :name, default: "?"
  field :email, default: "unknown"
  ignore :password
end

# alternatively, use the @default_view annotation
@default_view true
defview :front_end do
  # ...
end

...
```

After generation, the module will have function definitions similar to the following:

```elixir
def to_view(%User{}, view \\ :front_end)
def to_view(%User{}, :front_end)
def to_view(%User{}, :third_party_api)

# plus corresponding from_view functions
```

With this layout, you can let pattern matching determining which view to use.

## Key Naming Strategies

A common requirement for views is to translate struct keys to another naming  
convention, as snake case is not always the norm. To support this use case,
a view can be annotated with `@naming_strategy` and by default, the generated
aliases will use the new naming convention.

```elixir
defstruct [:field_one, :field_two]

@naming_strategy :camel
defview do
  field :field_one, as: "something" # explicit field aliases take precedence
end
```

Available naming strategies are: `:camel`, `:constant`, `:dot`, `:kebab`, `:pascal`, and `:path`.
  
Refer to [Recase](https://hexdocs.pm/recase) for details.

## Rationale

While interfacing with an external API written in Java, I frequently ran across 
instances in which I would need to map a struct's key, ignore certain fields, 
or add constant fields to outgoing requests. The process of setting up these mappings
is tiresome and potentially error prone.

Let's take a small, real-world example. This is the required JSON format
for a port in an unnamed API:

```json
{
  "$": 7000,
  "@enabled": false
}
```
Formats such as this were scattered throughout the API, leading to several
modules with structures similar to the following:

```elixir
defmodule Port do
  defstruct [:num, :enabled]

  def to_view(%Port{num: num, enabled: enabled}) do
    %{
      "$" => num,
      "@enabled" => enabled
    }
  end

  def from_view(%{"$" => num, "@enabled" => enabled}) do
    %Port{num: num, enabled: enabled}
  end
end
```

Code like this:

- is necessary to maintain a clean internal structure
- adds more noise than meaning
- can be error prone

Given these conditions, I opted to break my first rule of writing macros in Elixir
(avoid them). Instead of the example seen above, using `mine` allows for a much more
concise representation of a mapping to the external world.

```elixir
defmodule Port do
  use Mine
  defstruct [:num, :enabled]

  defview do
    field :num, "$"
    field :enabled, "@enabled"
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
    {:mine, "~> 0.3.2"}
  ]
end
```

## Benchmarking

To benchmark the generated functions against those written by hand, run the 
following:

```shell script
MIX_ENV=bench mix run bench/run.exs
```
