ExUnit.start()

Code.eval_file("asm.ex")

defmodule AsmTest do
  use ExUnit.Case, async: true

  describe "run/1" do
    test "performs an infinite loop with first sample code" do
      assert {:error, :loop, _, acc} =
               "input.sample.txt"
               |> Asm.parse()
               |> Asm.run()

      assert acc == 5
    end

    test "completes patched code" do
      assert {:ok, 8} =
               "input.sample2.txt"
               |> Asm.parse()
               |> Asm.patch(7)
               |> Asm.run()
    end
  end

  describe "at/2" do
    test "returns the instruction at the given index" do
      assert {:acc, -99} ==
               "input.sample.txt"
               |> Asm.parse()
               |> Asm.at(5)
    end
  end

  describe "patch/2" do
    test "alters nop -> jmp in program at the given index" do
      assert {:jmp, 0} ==
               "input.sample2.txt"
               |> Asm.parse()
               |> Asm.patch(0)
               |> Asm.at(0)
    end

    test "alters jmp -> nop in the program at the given index" do
      assert {:nop, 4} ==
               "input.sample2.txt"
               |> Asm.parse()
               |> Asm.patch(2)
               |> Asm.at(2)
    end

    test "does not change acc instructions" do
      assert {:acc, 1} ==
               "input.sample2.txt"
               |> Asm.parse()
               |> Asm.patch(1)
               |> Asm.at(1)
    end
  end
end
