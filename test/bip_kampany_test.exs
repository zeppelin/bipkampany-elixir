defmodule BipKampanyTest do
  use ExUnit.Case, async: true
  import Mock

  defp httpoison_response_json(dict) do
    { :ok, %{ body: Poison.encode!(dict) } }
  end


  setup do
    {:ok, config: %BipKampany.Config{
        email: "gabor.babicz@gmail.com",
        password: "hello",
        params: %{}
      }
    }
  end


  test "config object", context do
    config = BipKampany.Config.new([
      email: "gabor.babicz@gmail.com",
      password: "hello"
    ])

    assert config == context.config
  end

  test "get balance", context do
    response_body = httpoison_response_json(%{
        result: "OK",
        message: "A kerest sikeresen teljesitettuk.",
        balance: "30.00",
        currency: "HUF",
        limit: "40000"
    })

    with_mock HTTPoison, [get: fn(_url) -> response_body end] do
      result = context.config |> BipKampany.Api.get_balance

      assert called HTTPoison.get("http://api.bipkampany.hu/getbalance?email=gabor.babicz@gmail.com&format=json&password=hello")
      assert result == %{
        "result" => "OK",
        "message" => "A kerest sikeresen teljesitettuk.",
        "balance" => "30.00",
        "currency" => "HUF",
        "limit" => "40000"
      }
    end
  end

  test "get charset", context do
    response_body = httpoison_response_json(%{
      result: "OK",
      message: "A kerest sikeresen teljesitettuk.",
      charset: "@\u00a3$\u00a5\u00e8\u00e9\u00f9\u00ec\u00f2\u00c7\u00d8\u00f8\u00c5\u00e5\u0394_\u03a6\u0393\u039b\u03a9\u03a0\u03a8\u03a3\u0398\u039e\u00c6\u00e6\u00df\u00c9 !\"#\u00a4%&'()*+,-.\/0123456789:;<=>?\u00a1ABCDEFGHIJKLMNOPQRSTUVWXYZ\u00c4\u00d6\u00d1\u00dc\u00a7\u00bfabcdefghijklmnopqrstuvwxyz\u00e4\u00f6\u00f1\u00fc\u00e0\u00e1\u00ed\u00e9\u00f3\u00fa\u00c1\u00cd\u00da\u00d3\u0151\u0150\u0171\u0170"
    })

    with_mock HTTPoison, [get: fn(_url) -> response_body end] do
      result = context.config |> BipKampany.Api.get_charset

      assert called HTTPoison.get("http://api.bipkampany.hu/getcharset?email=gabor.babicz@gmail.com&format=json&password=hello")
      assert result == %{
        "result" => "OK",
        "message" => "A kerest sikeresen teljesitettuk.",
        "charset" => "@\u00a3$\u00a5\u00e8\u00e9\u00f9\u00ec\u00f2\u00c7\u00d8\u00f8\u00c5\u00e5\u0394_\u03a6\u0393\u039b\u03a9\u03a0\u03a8\u03a3\u0398\u039e\u00c6\u00e6\u00df\u00c9 !\"#\u00a4%&'()*+,-.\/0123456789:;<=>?\u00a1ABCDEFGHIJKLMNOPQRSTUVWXYZ\u00c4\u00d6\u00d1\u00dc\u00a7\u00bfabcdefghijklmnopqrstuvwxyz\u00e4\u00f6\u00f1\u00fc\u00e0\u00e1\u00ed\u00e9\u00f3\u00fa\u00c1\u00cd\u00da\u00d3\u0151\u0150\u0171\u0170"
      }
    end
  end

  test "cancel sms", context do
    response_body = httpoison_response_json(%{
      result: "OK",
      code: 0,
      message: "A kerest sikeresen teljesitettuk.",
    })

    with_mock HTTPoison, [get: fn(_url) -> response_body end] do
      result = context.config
      |> BipKampany.Api.cancel_sms([1, 2, 3])

      assert called HTTPoison.get("http://api.bipkampany.hu/cancelsms?email=gabor.babicz@gmail.com&format=json&password=hello&referenceid=1,2,3")
      assert result == %{
        "result" => "OK",
        "code" => 0,
        "message" => "A kerest sikeresen teljesitettuk."
      }
    end
  end
end
