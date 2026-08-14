defmodule TelegramEx.EffectTest do
  use ExUnit.Case
  require TelegramEx.Effect
  alias TelegramEx.Effect

  test "on_error matches, calls function and returns same effect" do
    effect = %Effect{ctx: %{foo: "bar"}, error: {:file, :some_error}}

    new_effect =
      effect
      |> Effect.on_error({:file, :some_error}, fn effect ->
        assert effect.error == {:file, :some_error}
      end)

    assert new_effect == effect
  end

  test "on_error calls zero-argument functions" do
    effect = %Effect{ctx: %{foo: "bar"}, error: {:file, :some_error}}

    new_effect =
      effect
      |> Effect.on_error({:file, :some_error}, fn ->
        assert true
      end)

    assert new_effect == effect
  end

  test "recover matches, calls function and returns recovered effect" do
    effect = %Effect{ctx: %{foo: "bar"}, error: {:file, :some_error}}

    new_effect =
      effect
      |> Effect.recover({:file, :some_error}, fn effect ->
        assert effect.error == {:file, :some_error}
        :ok
      end)

    assert new_effect == %Effect{ctx: %{foo: "bar"}, error: nil}
  end

  test "recover calls zero-argument functions" do
    effect = %Effect{ctx: %{foo: "bar"}, error: {:file, :some_error}}

    new_effect =
      effect
      |> Effect.recover({:file, :some_error}, fn ->
        :ok
      end)

    assert new_effect == %Effect{ctx: %{foo: "bar"}, error: nil}
  end

  test "recover_with matches, calls function and returns recovered effect with new ctx" do
    effect = %Effect{ctx: %{foo: "bar"}, error: {:file, :some_error}}

    new_effect =
      effect
      |> Effect.recover_with({:file, :some_error}, fn effect ->
        assert effect.error == {:file, :some_error}
        {:ok, %{foo: "baz"}}
      end)

    assert new_effect == %Effect{ctx: %{foo: "baz"}, error: nil}
  end

  test "recover_with passes effect to one-argument functions" do
    effect = %Effect{ctx: %{foo: "bar"}, error: {:file, :some_error}}

    new_effect =
      effect
      |> Effect.recover_with({:file, :some_error}, fn effect ->
        assert effect.error == {:file, :some_error}
        {:ok, Map.put(effect.ctx, :foo, "baz")}
      end)

    assert new_effect == %Effect{ctx: %{foo: "baz"}, error: nil}
  end

  test "recover_with calls zero-argument functions" do
    effect = %Effect{ctx: %{foo: "bar"}, error: {:file, :some_error}}

    new_effect =
      effect
      |> Effect.recover_with({:file, :some_error}, fn ->
        {:ok, %{foo: "baz"}}
      end)

    assert new_effect == %Effect{ctx: %{foo: "baz"}, error: nil}
  end
end
