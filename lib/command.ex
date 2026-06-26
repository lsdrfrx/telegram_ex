defmodule TelegramEx.Command do
  @moduledoc """
  Struct representing a Telegram command.

  This struct contains information about a command received from a user,
  including the command name, arguments, and the original message.

  ## Fields

  - `:command` - The command name (string)
  - `:args` - List of arguments passed with the command (list of strings)
  - `:message` - The original message struct (TelegramEx.Types.Message.t())

  ## Examples

      def handle_command(%Command{command: "start", args: args, message: msg}, ctx) do
        # Handle the /start command
        ctx
        |> Command.reply("Welcome! You sent: \#{Enum.join(args, " ")}", msg.chat["id"])
      end
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

  def register_all(token, module) do
    module.__commands__() |> API.set_my_commands(token)
  end

  defmacro defcommand(command_name, opts, do: block) do
    bind = Keyword.get(opts, :bind, [])

    message_var = Macro.var(:message, nil)
    ctx_var = Macro.var(:ctx, nil)
    args_var = Macro.var(:args, nil)
    command_var = Macro.var(:command, nil)
    description = Keyword.get(opts, :description, nil)

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
end
