defmodule Berkeley.Auth.OAuth do
  @moduledoc false
  alias Assent.Config

  def request(provider) do
    if config = config(provider) do
      config = Config.put(config, :redirect_uri, build_uri(provider))
      config[:strategy].authorize_url(config)
    else
      {:not_found, "No provider configuration for #{provider}"}
    end
  end

  def callback(provider, params, session_params \\ %{}) do
    if config = config(provider) do
      config =
        config
        |> Config.put(:session_params, session_params)
        |> Config.put(:redirect_uri, build_uri(provider))

      config[:strategy].callback(config, params)
    else
      {:not_found, "Invalid callback"}
    end
  end

  defp config(provider) do
    Application.get_env(:berkeley, :strategies)[String.to_existing_atom(provider)]
  rescue
    ArgumentError ->
      nil
  end

  defp build_uri(provider) do
    "#{Berkeley.Endpoint.url()}/api/account/#{provider}/callback"
  end
end
