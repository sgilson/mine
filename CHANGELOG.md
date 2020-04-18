# Changelog

## v0.3.0

### Breaking Change
- Renaming functions to be more concise. `alias_field` -> `field`, `add_field` ->
  `append`, `ignore_field` -> `ignore`. Larger structs made the verbosity of the
  previous method names obvious. I apologize for the breaking change, but I think
  this new language will be more concise.
  
### Improvements
- Can optionally restrict which functions are generated using `:only`
  in the `use` statement. For example, if you only wanted to generate the
  `to_view` function, you would define your module like the following:
  ```elixir
  defmodule YourModule do
    use Mine, only: :to_view
  
    # ... rest of module
  end
  ```

## v0.2.3

### Improvements
- Cleaning up generation logic a bit. Use of `Macro.var/2` was potentially unsafe,
  but all uses have been addressed.
- Explicitly limiting Mine macros allowed within `defview`.
- `from_view/2` will now only match on maps. Previous implementation matched 
  everything, which 1) caused errors inside Mine if a map was not 
  passed, 2) blocked client modules from defining additional `from_view/2` methods.
  This appears to have a small performance impact, but the safety is worth it.
  
### Other
- Getting reliable benchmarks is still an issue. The generated code is identical
  to that written by hand, yet the performance seems to vary up to 60% in both
  directions. Sometimes vanilla Elixir is faster, sometimes they are the same,
  sometimes, Mine is faster. Disabling power management, closing all other 
  programs, and manually triggering garbage collection between scenarios did 
  not improve reliability.

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