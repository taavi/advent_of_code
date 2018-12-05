defmodule P do
  def react(s) do
    s2 = s |> react([]) |> react([])
    if s == s2 do
      s
    else
      react(s2)
    end
  end

  defp react([], acc), do: acc
  for {lower, upper} <- Enum.zip(?a..?z, ?A..?Z) do
    defp react([unquote(lower), unquote(upper) | rest], acc), do: react(rest, acc)
    defp react([unquote(upper), unquote(lower) | rest], acc), do: react(rest, acc)
  end
  defp react([h | rest], acc), do: react(rest, [h | acc])
end

File.read!("input.txt")
|> String.trim
|> String.to_charlist
|> (fn s ->
  Enum.zip(?a..?z, ?A..?Z)
  |> Enum.map(fn {lower, upper} -> s |> Enum.filter(fn c -> c != lower && c != upper end) end)
end).()
|> Task.async_stream(&P.react/1)
|> Enum.map(fn {:ok, s} -> length(s) end)
|> Enum.min
|> IO.puts

# 4572
# takes as little as 3s!
# 2s when optimized
