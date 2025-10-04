defmodule MCPrelude do
  @type seed :: {:Seed, integer()}
  defmacro seed(seed), do: {:Seed, seed}

  @spec mkSeed(integer) :: seed
  def mkSeed(seed), do: seed(seed)

  @m 0x7FFFFFFF
  @type rand(seed) :: {integer, seed}
  def rand(seed(s)) do
    s2 = rem(s * 16807, @m)
    {s2, seed(s2)}
  end

  @doc """
  a char can be made into a binary like so:
  iex> <<?a>>
  "a"
  """
  @spec toLetter(integer) :: char
  def toLetter(char) do
    ?a + rem(char, 26)
  end

  @type greekData :: [{binary, [integer]}]

  @spec greekDataA :: greekData
  def greekDataA do
    [
      {"alpha", [5, 10]},
      {"beta", [0, 8]},
      {"gamma", [18, 47, 60]},
      {"delta", [42]}
    ]
  end

  @spec greekDataB :: greekData
  def greekDataB do
    [
      {"phi", [53, 13]},
      {"chi", [21, 8, 191]},
      {"psi", []},
      {"omega", [6, 82, 144]}
    ]
  end

  @spec salaries :: [{binary, integer}]
  def salaries do
    [
      {"alice", 105000},
      {"bob", 90000},
      {"carol", 85000}
    ]
  end

  @spec firstNames :: [binary]
  def firstNames, do: ["alice", "bob", "carol", "dave"]

  @spec lastNames :: [binary]
  def lastNames, do: ["doe", "jones", "smith"]

  @spec cardRanks :: [integer]
  def cardRanks, do: [2, 3, 4, 5]

  @spec cardSuits :: [binary]
  def cardSuits, do: ["H", "D", "C", "S"]

  defmacro m(do: {:__block__, _context, body}) do
    rec_mdo(Monad, body)
    |> case do x -> IO.puts(Macro.to_string(x)) ; x end
  end

  def rec_mdo(_module, [{:<-, context, _}]) do
    raise "Error line #{Keyword.get(context, :line, :unknown)}: end of monadic do should be a monadic value"
  end

  def rec_mdo(_module, [line]) do
    line
  end

  def rec_mdo(module, [{:<-, _context, [binding, expression]} | tail]) do
    quote location: :keep do
      unquote(expression)
      |> unquote(module).bind(fn unquote(binding) ->
        unquote(rec_mdo(module, tail))
      end)
    end
  end

  def rec_mdo(module, [{:=, _context, [_binding, _expression]} = line | tail]) do
    quote location: :keep do
      unquote(line)
      unquote(rec_mdo(module, tail))
    end
  end

  def rec_mdo(module, [expression | tail]) do
    quote location: :keep do
      unquote(expression)
      |> unquote(module).bind(fn _ ->
        unquote(rec_mdo(module, tail))
      end)
    end
    #|> case do x -> IO.puts(Macro.to_string(x)) ; x end
  end
end
