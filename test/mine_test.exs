defmodule MineTest do
  use ExUnit.Case, async: true
  import CompilerAssertions

  doctest Mine

  describe "basic user" do
    defmodule BasicUser do
      use Mine
      defstruct [:email, :name, pass: "*"]

      default_view(:api)

      defview :api do
        field(:email, as: "contact", default: "?")
        ignore(:pass)
        append("@class", "Some.Java.class")
      end

      defview :short do
        ignore(:pass)
        ignore(:email)
        field(:name, default: "Joe")
      end
    end

    test "module only exports expected functions" do
      allowed_funs = ~w(from_view to_view)a

      BasicUser.module_info()
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

    test "correct mappings for :api view" do
      struct = %BasicUser{
        email: "abc@d.com",
        pass: "secret!",
        name: "Bobby"
      }

      out = %{
        "name" => "Bobby",
        "contact" => "abc@d.com",
        "@class" => "Some.Java.class"
      }

      assert out == BasicUser.to_view(struct, :api)

      assert %BasicUser{email: "abc@d.com", name: "Bobby", pass: "*"} ==
               BasicUser.from_view(out, :api)
    end

    test ":api is the default" do
      struct = %BasicUser{
        email: "abc@d.com",
        pass: "secret!",
        name: "Bobby"
      }

      view = BasicUser.to_view(struct)

      assert Map.has_key?(view, "@class")
    end

    test "field will use field name if :as is missing" do
      struct = %BasicUser{
        email: "abc@d.com",
        pass: "secret!"
      }

      expected_view = %{"name" => "Joe"}

      assert expected_view == BasicUser.to_view(struct, :short)
      assert %BasicUser{name: "Joe"} == BasicUser.from_view(expected_view, :short)
    end
  end

  describe "mapped user - reference after" do
    defmodule MappedUser do
      use Mine
      defstruct [:name]

      def join_name(%{first: first, last: last}), do: first <> " " <> last

      def split_name(first_last) do
        [first, last] = String.split(first_last, " ")
        %{first: first, last: last}
      end

      defview do
        field(
          :name,
          as: "full_name",
          map_to: &join_name/1,
          map_from: &split_name/1
        )
      end
    end

    defmodule ReferenceModuleAfter do
      use Mine
      defstruct [:sender]

      defview do
        field(
          :sender,
          map_to: &MappedUser.to_view/1,
          map_from: &MappedUser.from_view/1
        )
      end
    end

    test "full_name field is computed" do
      struct = %MappedUser{
        name: %{
          first: "John",
          last: "Doe"
        }
      }

      assert %{"full_name" => "John Doe"} = MappedUser.to_view(struct)
    end

    test "full_name field is derived" do
      input = %{"full_name" => "John Doe"}

      assert %MappedUser{
               name: %{
                 first: "John",
                 last: "Doe"
               }
             } = MappedUser.from_view(input)
    end

    test "can use the to/from view functions of other module" do
      nested_user = %MappedUser{
        name: %{
          first: "John",
          last: "Doe"
        }
      }

      struct_after = %ReferenceModuleAfter{sender: nested_user}

      expected_view = %{
        "sender" => %{
          "full_name" => "John Doe"
        }
      }

      assert expected_view == ReferenceModuleAfter.to_view(struct_after)
      assert struct_after == ReferenceModuleAfter.from_view(expected_view)
    end
  end

  test "using macros outside defview/1" do
    assert_compiler_raise(
      ~r/(undefined function field)/i,
      CompileError,
      defmodule MisplacedAliasField do
        use Mine
        defstruct [:name, :pass]

        field(:name, "username")
      end
    )
  end

  test "using macros after defview/1" do
    assert_compiler_raise(
      ~r/(undefined function ignore)/i,
      CompileError,
      defmodule ExtraIgnoreField do
        use Mine
        defstruct [:name, :pass]

        defview :api do
          field(:name, "name")
        end

        ignore(:name)
      end
    )
  end

  test "name is validated" do
    assert_compiler_raise(
      ~r/(not a valid value)/,
      defmodule NameWithNumber do
        use Mine
        defstruct [:field]

        defview do
          field(:field, 1)
        end
      end
    )
  end

  test "using defview/1 without defstruct" do
    assert_compiler_raise(
      ~r/(struct)/,
      CompileError,
      defmodule MissingStruct do
        use Mine

        defview :api do
          field(:name, "name")
        end
      end
    )
  end

  test "using defview/1 before defstruct" do
    assert_compiler_raise(
      ~r/(struct)/,
      CompileError,
      defmodule BeforeStruct do
        use Mine

        defview :api do
          field(:name, "name")
        end

        defstruct [:name]
      end
    )
  end

  test "missing default view name" do
    assert_compiler_raise(
      ~r/(api).*(view does not exist)/,
      defmodule MissingViewName do
        use Mine
        defstruct [:name]

        default_view(:api)

        defview do
          field(:name, "name")
        end
      end
    )
  end

  test "aliasing name that is not in struct" do
    assert_compiler_raise(
      ~r/(does not exist)/,
      defmodule FieldDoesNotExist do
        use Mine
        defstruct [:name]

        default_view(:api)

        defview do
          field(:nombre, "name")
        end
      end
    )
  end

  test "aliasing name twice raises error" do
    assert_compiler_raise(
      ~r/(name is defined more than once)/,
      defmodule NameConflictAliasField do
        use Mine
        defstruct [:name]

        defview do
          field(:name, "a")
          field(:name, "b")
        end
      end
    )
  end

  test "view names are trivially validated" do
    assert_compiler_raise(
      ~r/1.*(not a valid view name)/,
      defmodule ViewNameIsNumber do
        use Mine

        defstruct [:name]

        defview 1 do
          field(:name, "a")
        end
      end
    )
  end

  test "key cannot be given multiple properties" do
    assert_compiler_raise(
      ~r/(name is defined more than once)/,
      defmodule NameConflictAliasAndIgnore do
        use Mine

        defstruct [:name]

        defview do
          field(:name, "a")
          ignore(:name)
        end
      end
    )
  end

  test "view names must be unique" do
    assert_compiler_raise(
      ~r/(view names must be unique)/,
      defmodule ViewNameConflict do
        use Mine

        defstruct [:name]

        default_view(:api)

        defview :api do
          field(:name, "a")
        end

        defview :api do
          field(:name, as: "b")
        end
      end
    )
  end

  test "can use complex values in append" do
    assert_compiles(
      defmodule ComplexAddField do
        use Mine
        defstruct [:field]

        defview do
          append("field2", %{"hello" => :world})
        end
      end
    )
  end

  test "can use a private mapper" do
    assert_compiles(
      defmodule PrivateMapper do
        use Mine
        defstruct [:field]

        defp identity(x), do: x

        defview do
          field(:field, map_to: &identity/1)
        end
      end
    )
  end

  test "can use anonymous function as mapper" do
    assert_compiles(
      defmodule AnonymousMapper do
        use Mine
        defstruct [:field]

        defview do
          field(:field, map_to: fn x -> x end)
        end
      end
    )
  end

  test "can use captured function as mapper" do
    assert_compiles(
      defmodule CaptureMapper do
        use Mine
        defstruct [:field]

        def identity(x), do: x

        defview do
          field(:field, map_to: &identity(&1))
        end
      end
    )
  end

  test "can use imported function as mapper" do
    assert_compiles(
      defmodule ImportedMapper do
        use Mine
        import String, only: [upcase: 1]
        defstruct [:field]

        defview do
          field(:field, map_to: &upcase/1)
        end
      end
    )
  end

  test "must give a function to map_to" do
    assert_compiler_raise(
      ~r/(should be a function)/,
      defmodule MapFrom1 do
        use Mine

        defstruct [:name]

        defview do
          field(:name, as: "Name", map_from: 1)
        end
      end
    )
  end

  test "must give a function to map_from" do
    assert_compiler_raise(
      ~r/(should be a function)/,
      defmodule MapTo1 do
        use Mine

        defstruct [:name]

        defview do
          field(:name, as: "Name", map_to: 1)
        end
      end
    )
  end

  test "defview is not in scope within defview" do
    assert_compiler_raise(
      ~r/(undefined function)/,
      CompileError,
      defmodule BadNesting do
        use Mine

        defstruct [:name]

        defview do
          field(:name, as: "Name", map_to: 1)

          defview :nested do
            field(:name, as: "Name", map_to: 1)
          end
        end
      end
    )
  end

  describe "overriding" do
    assert_compiles(
      defmodule Override do
        use Mine

        defstruct [:name]

        defview do
          field(:name, as: "Name")
        end

        def to_view(nil, :default), do: to_view(%Override{name: nil})
        def from_view(nil, :default), do: from_view(%{})
      end
    )

    test "can use overridden functions" do
      assert Override.to_view(nil, :default) == %{"Name" => nil}
      assert Override.from_view(nil, :default) == %Override{name: nil}
    end
  end

  describe "limiting generated functions" do
    assert_compiles(
      defmodule UsingOnlyOne do
        use Mine, only: :from_view

        defstruct [:name]

        defview do
          field(:name, as: "NAME")
        end
      end
    )

    test "to_view function was not generated" do
      refute Enum.member?(UsingOnlyOne.__info__(:functions), {:to_view, 1})
      refute Enum.member?(UsingOnlyOne.__info__(:functions), {:to_view, 2})
    end

    assert_compiles(
      defmodule UsingOnlyList do
        # using a list this time
        use Mine, only: [:to_view]

        defstruct [:name]

        defview do
          field(:name, as: "NAME")
        end
      end
    )

    test "from function was not generated" do
      refute Enum.member?(UsingOnlyList.__info__(:functions), {:from_view, 1})
      refute Enum.member?(UsingOnlyList.__info__(:functions), {:from_view, 2})
    end
  end
end
