defmodule MCPrelude.Curried do
  @type seed :: {:Seed, integer()}
  defmacro seed(seed), do: {:Seed, seed}

  def mkSeed(seed), do: seed(seed)

  @m 0x7FFFFFFF
  def rand do
    fn seed(s) ->
      s2 = rem(s * 16807, @m)
      {s2, seed(s2)}
    end
  end

  @doc """
  a char can be made into a binary like so:
      iex> <<?a>>
      "a"
  """
  def toLetter(char) do
    ?a + rem(char, 26)
  end
end
