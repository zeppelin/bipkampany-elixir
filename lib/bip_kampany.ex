defmodule BipKampany.Config do
  defstruct [:email, :password, params: %{}]

  def new([email: email, password: password]) do
    %BipKampany.Config{
      email: email,
      password: password
    }
  end
end

defmodule BipKampany.Api do
  alias BipKampany.Config

  @url "http://api.bipkampany.hu/"

  def get_balance(%Config{} = config) do
    config |> call("getbalance")
  end

  def get_charset(%Config{} = config) do
    config |> call("getcharset")
  end

  def send_sms(%Config{} = config, phone_number, message, sender_id) do
    params = %{
      number: phone_number,
      message: message,
      senderid: sender_id
    }

    config
    |> assign_params(params)
    |> call("sendsms")
  end

  def cancel_sms(%Config{} = config, reference_ids \\ []) do
    config
    |> assign_params(%{referenceid: Enum.join(reference_ids, ",")})
    |> call("cancelsms")
  end


  defp call(config, action) do
    base_url = "#{@url}#{action}"

    # Somehow `URI.encode_query` encodes stuff like `@` and `,`
    query_params =
      prepare_params(config)
      |> URI.encode_query
      |> URI.decode

    url = "#{base_url}?#{query_params}"
    {_status, response} = HTTPoison.get(url)

    Poison.decode! response.body
  end

  defp prepare_params(%Config{} = config) do
    credentials = %{
      email: config.email,
      password: config.password
    }

    defaults = %{
      format: "json"
    }

    config.params
    |> Dict.merge(credentials)
    |> Dict.merge(defaults)
  end

  defp assign_params(%Config{} = config, %{} = params) do
    Map.put(config, :params, params)
  end
end
