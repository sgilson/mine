# Changelog

## v0.2.2

### Improvements
-   Fixing scope issues. Previously, `map_to` and `map_from` were not able
    to access imported or required functions. Now all functions that are
    valid in the scope of a normal function will be available for use within
    `defview`.
-   Adding documentation for important macros. Top level documentation for Mine
    module is still lacking.
-   Switched to using `Macro.struct!` to determine whether the host module
    has declared a struct. These failures will now be CompileError instead of
    Mine.CompileError.
-   Lots of cleanup on the underlying implementation. Removed the use of processes
    to keep track of current progress in favor of writing to module attributes.
    Should increase stability and speed up compilation a bit.

## v0.2.1

### New Feature: Mapping Functions

-   `map_to` and `map_from`. 
-   When an anonymous (or captured) function with arity/1 is supplied to `alias_field` 
    using the mentioned key, values will be mapped after translation.
    ```elixir
    # Example module using mapping feature
    defmodule A do
      use Mine
      defstruct [:b]
    
      defview do
        alias_field :b, 
                    as: "B",
                    map_to: &String.upcase/1
      end
    end
    ```
-   Functions given to `map_to` and `map_from` maintain the scope of the
    caller. Private functions and aliases are honored. Imported functions
    are currently not supported.
-   Values supplied as mappers are trivially validated to be functions.

### Improvements
-   Macro hygiene. `alias_field`, `ignore_field`, etc are now scoped to 
    `defview`.
-   If `as` option is not passed to `alias_field`, the key name will be 
    turned into a string and used instead.
-   Fixed edge case where aliasing after a `defview` would complain because
    the view_agent was still registered but not alive.
    ```elixir
    # example
    defmodule C do
      use Mine
      # defines struct
    
      defview do
        # body
      end
    
      # would randomly cause a crash
      ignore_field(:some_field)
    end
    ```