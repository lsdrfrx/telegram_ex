defmodule TelegramEx do
  defmacro __using__(_opts) do
    quote do
      alias TelegramEx.API
      alias TelegramEx.Builder.Message
      alias TelegramEx.Config

      def child_spec(_) do
        %{
          id: __MODULE__,
          start: {TelegramEx.Bot.Server, :start_link, [__MODULE__, Config.token()]},
          type: :worker
        }
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
