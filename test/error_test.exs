defmodule TelegramEx.ErrorTest do
  use ExUnit.Case
  doctest TelegramEx.Error

  alias TelegramEx.Error

  test "from_body/1 captures code, description and retry_after" do
    body = %{
      "ok" => false,
      "error_code" => 429,
      "description" => "Too Many Requests: retry after 5",
      "parameters" => %{"retry_after" => 5}
    }

    assert %Error{
             type: :telegram,
             code: 429,
             description: "Too Many Requests: retry after 5",
             retry_after: 5,
             raw: ^body
           } = Error.from_body(body)
  end

  test "from_body/1 leaves retry_after nil when parameters are absent" do
    body = %{"error_code" => 400, "description" => "Bad Request: message is not modified"}

    assert %Error{code: 400, retry_after: nil} = Error.from_body(body)
  end
end
