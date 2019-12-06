defmodule MineTest do
  use ExUnit.Case, async: true
  import CompilerAssertions

  #  import ExUnit.CaptureLog
  require Logger

  @moduletag :capture_log

  doctest Mine

  describe "complex user" do
    defmodule ComplexUser do
      use Mine
      defstruct [:email, :name, pass: "*"]

      default_view(:api)

      defview :api do
        alias_field(:email, as: "contact", default: "?")
        ignore_field(:pass)
        add_field("@class", "Some.Java.class")
      end

      defview :short do
        ignore_field(:pass)
        ignore_field(:email)
      end
    end

    test "module only exports expected functions" do
      allowed_funs = ~w(from_view to_view)a

      ComplexUser.module_info()
      |> Keyword.fetch!(:exports)
      |> Enum.reject(fn {fun, _} ->
        case to_string(fun) do
          "__" <> _ -> true
          "module_info" -> true
          _ -> false
        end
      end)
      |> Enum.each(fn {fun, _} ->
        assert fun in allowed_funs
      end)
    end

    test ":api is the default" do
    end

    test "correct mappings for :api view" do
      struct = %ComplexUser{
        email: "abc@d.com",
        pass: "secret!",
        name: "Bobby"
      }

      out = %{
        "name" => "Bobby",
        "contact" => "abc@d.com",
        "@class" => "Some.Java.class"
      }

      assert out == ComplexUser.to_view(struct, :api)

      assert %ComplexUser{email: "abc@d.com", name: "Bobby", pass: "*"} ==
               ComplexUser.from_view(out, :api)
    end
  end

  test "using macros before defview/1" do
    assert_compile_time_raise(
      ~r/(alias_field cannot be used)/i,
      defmodule User0 do
        use Mine
        defstruct [:name, :pass]

        alias_field(:name, "username")
      end
    )
  end

  test "using macros after defview/1" do
    assert_compile_time_raise(
      ~r/(ignore_field cannot be used)/i,
      defmodule User0 do
        use Mine
        defstruct [:name, :pass]

        defview :api do
          alias_field(:name, "name")
        end

        ignore_field(:name)
      end
    )
  end

  test "using defview/1 without a struct present" do
    assert_compile_time_raise(
      ~r/(must define a struct)/,
      defmodule User2 do
        use Mine

        defview :api do
          alias_field(:name, "name")
        end
      end
    )
  end

  test "using defview/1 before struct is declared" do
    assert_compile_time_raise(
      ~r/(must define a struct)/,
      defmodule User3 do
        use Mine

        defview :api do
          alias_field(:name, "name")
        end

        defstruct [:name]
      end
    )
  end

  test "missing default view name" do
    assert_compile_time_raise(
      ~r/(api).*(view does not exist)/,
      defmodule User4 do
        use Mine
        defstruct [:name]

        default_view(:api)

        defview do
          alias_field(:name, "name")
        end
      end
    )
  end

  test "aliasing name that is not in struct" do
    assert_compile_time_raise(
      ~r/(does not exist)/,
      defmodule User5 do
        use Mine
        defstruct [:name]

        default_view(:api)

        defview do
          alias_field(:nombre, "name")
        end
      end
    )
  end

  test "aliasing name twice raises error" do
    assert_compile_time_raise(
      ~r/(name is defined more than once)/,
      defmodule User6 do
        use Mine
        defstruct [:name]

        defview do
          alias_field(:name, "a")
          alias_field(:name, "b")
        end
      end
    )
  end

  test "view names are trivially validated" do
    assert_compile_time_raise(
      ~r/1.*(not a valid view name)/,
      defmodule User7 do
        use Mine

        defstruct [:name]

        defview 1 do
          alias_field(:name, "a")
        end
      end
    )
  end

  test "key cannot be given multiple properties" do
    assert_compile_time_raise(
      ~r/(name is defined more than once)/,
      defmodule User8 do
        use Mine

        defstruct [:name]

        defview do
          alias_field(:name, "a")
          ignore_field(:name)
        end
      end
    )
  end

  test "view names must be unique" do
    assert_compile_time_raise(
      ~r/(view names must be unique)/,
      defmodule User9 do
        use Mine

        defstruct [:name]

        default_view(:api)

        defview :api do
          alias_field(:name, "a")
        end

        defview :api do
          alias_field(:name, as: "b")
        end
      end
    )
  end
end
