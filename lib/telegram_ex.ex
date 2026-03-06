defmodule TelegramEx do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @bot_name Keyword.fetch!(opts, :name)
      @bot_token Keyword.fetch!(opts, :token)

      alias TelegramEx.API

      def child_spec(_) do
        %{
          id: __MODULE__,
          start: {TelegramEx.Bot.Server, :start_link, [__MODULE__, @bot_token]},
          type: :worker
        }
      end

      def send_message(to, message) do
        API.send_message(@bot_token, to, message)
      end

      def send_photo(photo) do
        IO.inspect(photo)
      end

      def handle_message(_message), do: :ok
      def handle_callback(_callback), do: :ok
      def handle_inline(_inline), do: :ok

      defoverridable handle_message: 1,
                     handle_callback: 1,
                     handle_inline: 1
    end
  end
end
