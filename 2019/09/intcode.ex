defmodule Intcode do
  defstruct [:program, :ip, :relative_base]

  def load!(filename) do
    %__MODULE__{
      program: File.read!(filename)
        |> String.split(",")
        |> Enum.map(fn x ->
          x |> String.trim |> String.to_integer
        end)
        |> :array.from_list(0),
      ip: 0,
      relative_base: 0,
    }
  end

  def peek(intcode, address) do
    :array.get(address, intcode.program)
  end

  def poke(intcode, address, value) do
    %__MODULE__{ intcode | program: :array.set(address, value, intcode.program) }
  end

  @compile {:inline, arg_address: 3}
  def arg_address(intcode, opcode, arg_number)
  def arg_address(intcode, opcode, 1) when rem(div(opcode, 100), 10) == 0 do
    :array.get(intcode.ip + 1, intcode.program)
  end
  def arg_address(intcode, opcode, 2) when rem(div(opcode, 1000), 10) == 0 do
    :array.get(intcode.ip + 2, intcode.program)
  end
  def arg_address(intcode, opcode, 3) when rem(div(opcode, 10000), 10) == 0 do
    :array.get(intcode.ip + 3, intcode.program)
  end
  def arg_address(intcode, opcode, 1) when rem(div(opcode, 100), 10) == 1 do
    intcode.ip + 1
  end
  def arg_address(intcode, opcode, 2) when rem(div(opcode, 1000), 10) == 1 do
    intcode.ip + 2
  end
  def arg_address(intcode, opcode, 3) when rem(div(opcode, 10000), 10) == 1 do
    intcode.ip + 3
  end
  def arg_address(intcode, opcode, 1) when rem(div(opcode, 100), 10) == 2 do
    intcode.relative_base + :array.get(intcode.ip + 1, intcode.program)
  end
  def arg_address(intcode, opcode, 2) when rem(div(opcode, 1000), 10) == 2 do
    intcode.relative_base + :array.get(intcode.ip + 2, intcode.program)
  end
  def arg_address(intcode, opcode, 3) when rem(div(opcode, 10000), 10) == 2 do
    intcode.relative_base + :array.get(intcode.ip + 3, intcode.program)
  end

  @compile {:inline, arg_value: 3}
  def arg_value(intcode, opcode, arg_number) do
    :array.get(arg_address(intcode, opcode, arg_number), intcode.program)
  end

  def run(intcode, step \\ false, halt \\ false)
  def run(intcode, _, true), do: intcode
  def run(intcode, step, _) do
    opcode = :array.get(intcode.ip, intcode.program)
    case rem(opcode, 100) do

      1 ->
        %__MODULE__{
          intcode |
          program: :array.set(
            arg_address(intcode, opcode, 3),
            arg_value(intcode, opcode, 1) + arg_value(intcode, opcode, 2),
            intcode.program
          ),
          ip: intcode.ip + 4,
        }
        |> run(false, step)

      2 ->
        %__MODULE__{
          intcode |
          program: :array.set(
            arg_address(intcode, opcode, 3),
            arg_value(intcode, opcode, 1) * arg_value(intcode, opcode, 2),
            intcode.program
          ),
          ip: intcode.ip + 4,
        }
        |> run(false, step)

      3 ->
        %__MODULE__{
          intcode |
          program: :array.set(
            arg_address(intcode, opcode, 1),
            IO.gets("> ") |> String.trim |> String.to_integer,
            intcode.program
          ),
          ip: intcode.ip + 2
        }
        |> run(false, step)

      4 ->
        IO.puts(arg_value(intcode, opcode, 1))
        %__MODULE__{
          intcode | 
          ip: intcode.ip + 2
        }
        |> run(false, step)

      5 ->
        %__MODULE__{
          intcode | 
          ip: if arg_value(intcode, opcode, 1) != 0 do
              arg_value(intcode, opcode, 2)
            else
              intcode.ip + 3
            end
        }
        |> run(false, step)

      6 ->
        %__MODULE__{
          intcode | 
          ip: if arg_value(intcode, opcode, 1) == 0 do
              arg_value(intcode, opcode, 2)
            else
              intcode.ip + 3
            end
        }
        |> run(false, step)

      7 ->
        %__MODULE__{
          intcode |
          program: :array.set(
            arg_address(intcode, opcode, 3),
            if arg_value(intcode, opcode, 1) < arg_value(intcode, opcode, 2) do 1 else 0 end,
            intcode.program
          ),
          ip: intcode.ip + 4
        }
        |> run(false, step)

      8 ->
        %__MODULE__{
          intcode |
          program: :array.set(
            arg_address(intcode, opcode, 3),
            if arg_value(intcode, opcode, 1) == arg_value(intcode, opcode, 2) do 1 else 0 end,
            intcode.program
          ),
          ip: intcode.ip + 4
        }
        |> run(false, step)

      9 ->
        %__MODULE__{
          intcode |
          ip: intcode.ip + 2,
          relative_base: intcode.relative_base + arg_value(intcode, opcode, 1),
        }
        |> run(false, step)

      99 ->
        intcode

    end
  end

  def answer_1(filename \\ "input.txt") do
    load!(filename)
    |> run
  end
end
