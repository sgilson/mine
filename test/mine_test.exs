defmodule MineTest do
  use ExUnit.Case, async: true
  import CompilerAssertions

  import ExUnit.CaptureLog
  require Logger

  @moduletag :capture_log

  doctest Mine

  test "module exists" do
    assert is_list(Mine.module_info())
  end

  describe "negative tests" do
    test "using macros outside defview/1" do
      assert_compile_time_raise(
        ~r/(alias_field cannot be used)/i,
        defmodule User1 do
          use Mine
          defstruct [:name, :pass]

          alias_field(:name, "username")
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
        ~r/(name has already been aliased)/,
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

    test "key cannot be aliased and ignore_fieldd" do
      assert_compile_time_raise(
        ~r/(alias_field).*(ignore_field)/,
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
  end

  describe "simple user" do
    defmodule SimpleUser do
      use Mine
      defstruct [:email, :name, :pass]

      defview do
        alias_field(:email, "contact")
        alias_field(:name, as: "user", default: "John Doe")
        ignore_field(:pass)
      end
    end

    test "module only exports expected functions" do
      allowed_funs = ~w(from_view from_view! new_instance normalize to_view validate)a

      SimpleUser.module_info()
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

    test "basic" do
      assert view =
               %{
                 "contact" => "a@b.com",
                 "user" => "bob"
               } = SimpleUser.to_view(%SimpleUser{email: "a@b.com", name: "bob", pass: "ssh"})

      assert %SimpleUser{email: "a@b.com", name: "bob"} = SimpleUser.from_view!(view)
    end

    test "with default" do
      assert view =
               %{
                 "contact" => "a@b.com",
                 "user" => "John Doe"
               } = SimpleUser.to_view(%SimpleUser{email: "a@b.com", pass: "ssh"})

      assert %SimpleUser{email: "a@b.com", name: "John Doe"} = SimpleUser.from_view!(view)
    end
  end

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

      def validate(struct) do
        case struct do
          %ComplexUser{} -> Logger.info("validate called with struct!")
          _ -> Logger.error("not a struct! #{inspect(struct)}")
        end

        {:ok, struct}
      end
    end

    test ":api is the default" do
      assert %{"@class" => _} = ComplexUser.to_view(%ComplexUser{})
      assert %ComplexUser{email: "hi"} = ComplexUser.from_view!(%{"contact" => "hi"})
    end

    test "correct mappings for :api view" do
      assert %{"contact" => "?", "name" => "Bob", "@class" => "Some.Java.class"} =
               ComplexUser.to_view(%ComplexUser{name: "Bob", pass: "secret"})
    end

    test "validate is called in from_view and passed a struct" do
      assert capture_log(fn -> ComplexUser.from_view!(%{}) end) =~ "validate called with struct!"
    end
  end
end
