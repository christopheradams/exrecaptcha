defmodule Exrecaptcha do
  require Elixir.EEx

  # Define display function to be read in .eex file
  EEx.function_from_file :defp, :display, "lib/display.eex", [:public_key]

  def display do
    display conf.public_key
  end

  def verify(remote_ip, challenge, response) when is_tuple(remote_ip) do
    verify(to_string(:inet_parse.ntoa(remote_ip)), challenge, response)
  end
  def verify(remote_ip, challenge, response) do
    query = URI.encode_query(%{"privatekey" => conf.private_key,
                               "remoteip" => remote_ip,
                               "challenge" => challenge,
                               "response" => response})

    headers = ["Content-type": "application/x-www-form-urlencoded",
               "User-agent": "reCAPTCHA Elixir"]
    request_url = conf.verify_url <> "?" <> query

    http_response = HTTPotion.post request_url, [headers: headers]
    %{:body => body} = http_response

    check_result String.split(body)
  end

  defp conf do
    Application.get_env(:exrecaptcha, :api_config)
  end

  defp check_result(["true", result]) do
    {:ok, result}
  end
  defp check_result(["false", reason]) do
    {:error, reason}
  end

end
