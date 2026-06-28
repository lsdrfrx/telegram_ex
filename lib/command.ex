defmodule TelegramEx.Command do
  @moduledoc """
  Helpers for defining and registering Telegram bot commands.

  `defcommand/3` defines a regular `handle_message/2` clause for messages that
  start with a Telegram command and stores metadata for `setMyCommands`.

  `register_all/2` is called by `TelegramEx.Server` on startup. It reads command
  metadata from the bot module and its routers, then sends the list to Telegram
  using `setMyCommands`.

  See [Commands](commands.md) for examples and binding rules.

  ## Fields

  - `:command` - The command name (string)
  - `:description` - Command description used by Telegram clients
  - `:message` - The original message struct (TelegramEx.Types.Message.t())
  """

  alias TelegramEx.API

  @typedoc """
  Command struct type.

  Contains all fields related to a Telegram command.
  """
  @type t :: %__MODULE__{
          command: String.t(),
          description: String.t() | nil,
          message: TelegramEx.Types.Message.t()
        }

  defstruct [
    :command,
    :description,
    :message
  ]

  @doc """
  Registers all commands defined in a bot module and its routers.
  """
  @spec register_all(String.t(), module()) :: :ok | {:error, term()}
  def register_all(token, module) do
    commands =
      module
      |> command_modules()
      |> Enum.flat_map(&module_commands/1)
      |> Enum.uniq_by(& &1.command)

    API.set_my_commands(commands, token)
  end

  @doc """
  Defines a command handler and adds the command to the module metadata.

  The command name should be passed without the leading slash. `:description`
  is required because Telegram requires it for `setMyCommands`.

  See [Commands](commands.md) for full examples.
  """
  defmacro defcommand(command_name, opts, do: block) do
    bind = Keyword.get(opts, :bind, [])

    message_var = Macro.var(:message, nil)
    ctx_var = Macro.var(:ctx, nil)
    args_var = Macro.var(:args, nil)
    command_var = Macro.var(:command, nil)
    description = Keyword.fetch!(opts, :description)

    args_assignment =
      if :args in bind do
        quote do
          unquote(args_var) = String.split(unquote(message_var).text, " ") |> Enum.drop(1)
        end
      end

    command_assignment =
      if :command in bind do
        quote do
          unquote(command_var) = %TelegramEx.Command{
            command: unquote(command_name),
            description: unquote(opts[:description]),
            message: unquote(message_var)
          }
        end
      end

    bindings =
      for name <- bind do
        var = Macro.var(name, nil)

        source =
          case name do
            :message -> message_var
            :ctx -> ctx_var
            :args -> args_var
            :command -> command_var
            _ -> raise ArgumentError, "Unsupported bind variable: #{name}."
          end

        quote do
          var!(unquote(var)) = unquote(source)
        end
      end

    quote do
      @commands %{command: unquote(command_name), description: unquote(description)}

      def handle_message(
            %{text: "/#{unquote(command_name)}" <> _rest} = unquote(message_var),
            unquote(ctx_var)
          ) do
        unquote(args_assignment)
        unquote(command_assignment)
        unquote_splicing(bindings)

        unquote(block)
      end
    end
  end

  defp command_modules(module) do
    routers =
      if function_exported?(module, :__routers__, 0),
        do: module.__routers__(),
        else: []

    [module | routers]
  end

  defp module_commands(module) do
    if function_exported?(module, :__commands__, 0),
      do: module.__commands__(),
      else: []
  end
end
