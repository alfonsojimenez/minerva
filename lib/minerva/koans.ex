defmodule Minerva.Koans do
  @moduledoc false

  alias Minerva.Assertions

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :tests, accumulate: true)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def run do
        Assertions.run(Enum.reverse(@tests), __MODULE__)
      end
    end
  end

  defmacro koan(description, do: test_block) do
    test_func = String.to_atom(description)

    quote do
      @tests {unquote(test_func), unquote(description)}
      def unquote(test_func)() do
        var!(description) = unquote(description)
        var!(module) = __MODULE__ |> Module.split |> List.last
        var!(___) = "___"
        try do
          unquote(test_block)
        rescue
          _ ->
        end
      end
    end
  end

  defmacro assert({operator, _, [left, right]} = code) do
    code = Macro.escape(code)
    quote bind_quoted: [
      operator: operator, left: left, right: right, code: code
    ] do
      Assertions.assert(
        operator,
        left,
        right,
        %{
          description: var!(description),
          module: var!(module),
          code: Macro.to_string(code)
        }
      )
    end
  end

  defmacro assert(boolean) do
    quote bind_quoted: [boolean: boolean] do
      Assertions.assert(
        boolean,
        %{
          description: var!(description),
          module: var!(module),
          code: boolean,
        }
      )
    end
  end
end
